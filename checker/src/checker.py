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
    GetflagCheckerTaskMessage,
    MumbleException,
    PutflagCheckerTaskMessage,
)
from enochecker3.utils import FlagSearcher, assert_equals, assert_in
from httpx import AsyncClient

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


def ints_to_class(name: str, ints: List[int], length: int) -> str:
    s = "class " + name + " {\n"
    s += f"  private static int secret_length = {str(length)};\n"
    strs = [
        f"  private static int secret_{str(i)} = {str(v)};" for i, v in enumerate(ints)
    ]
    s += "\n".join(strs) + "\n"
    s += "}\n"
    return s


@checker.putflag(0)
async def putflag_test(
    task: PutflagCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> None:
    class_name = "".join(secrets.choice(string.ascii_uppercase) for i in range(5))

    l, ints = flag_to_ints(task.flag)
    class_body = ints_to_class(class_name, ints, l)

    with open(f"{class_name}.java", "w") as f:
        f.write(class_body)

    subprocess.run(["javac", f"{class_name}.java"], check=True)

    files = {"fileToUpload": open(f"{class_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{class_name}.java")
    os.remove(f"{class_name}.class")
    print()
    print()
    print()
    print(r)
    print(r.text)
    print()
    print()
    print()
    assert_equals(r.status_code, 200, "storing class with flag failed")
    m = re.search(r"href='runner.php\?replay_id=(.*?)'", r.text)

    await db.set("replay_id", m.group(1))


@checker.getflag(0)
async def getflag_test(
    task: GetflagCheckerTaskMessage, client: AsyncClient, db: ChainDB
) -> None:
    try:
        token = await db.get("replay_id")
    except KeyError:
        raise MumbleException("Missing database entry from putflag")

    r = await client.get(f"/runner.php?replay_id={token}")
    assert_equals(r.status_code, 200, "getting note with flag failed")
    print()
    print()
    print()
    print(r)
    print(r.text)
    print()
    print()
    print()

    # TODO ints_to_flag
    assert_in(task.flag, r.text, "flag missing from note")


@checker.exploit(0)
async def exploit_test(searcher: FlagSearcher, client: AsyncClient) -> Optional[str]:
    r = await client.get(
        "/note/*",
    )
    assert not r.is_error

    if flag := searcher.search_flag(r.text):
        return flag
