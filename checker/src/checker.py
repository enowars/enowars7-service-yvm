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


def ints_to_class(name: str, ints: List[int], length: int, private: bool) -> str:
    if private:
        acc_lvl = "private"
    else:
        acc_lvl = "public"

    s = "class " + name + " {\n"
    s += f"  {acc_lvl} static int secret_length = {length};\n"
    strs = [
        f"   {acc_lvl} static int secret_{str(i)} = {str(v)};"
        for i, v in enumerate(ints)
    ]
    s += "\n".join(strs) + "\n"
    s += "  public static void main(String[] args) { }\n"
    s += "}\n"
    return s


def gen_name() -> str:
    return "".join(secrets.choice(string.ascii_uppercase) for i in range(5))


@checker.putflag(0)
async def putflag_test(
    task: PutflagCheckerTaskMessage,
    logger: LoggerAdapter,
    client: AsyncClient,
    db: ChainDB,
) -> str:
    class_name = gen_name()

    l, ints = flag_to_ints(task.flag)
    class_body = ints_to_class(class_name, ints, l, True)

    with open(f"{class_name}.java", "w") as f:
        f.write(class_body)

    subprocess.run(["javac", f"{class_name}.java"], check=True)

    files = {"fileToUpload": open(f"{class_name}.class", "rb")}
    r = await client.post("/runner.php", files=files)

    os.remove(f"{class_name}.java")
    os.remove(f"{class_name}.class")

    assert_equals(r.status_code, 200, "storing class with flag failed")

    if m := re.search(r"href='runner.php\?replay_id=(.*?)'", r.text):
        await db.set("replay_id", m.group(1))
        return json.dumps({"no_ints": len(ints), "class_name": class_name})
    else:
        raise MumbleException("No replay_id returned by service")


def reconstruct_flag(text: str) -> str:
    if m := re.search(
        r'\(\("secret_length", "I"\), ref \(\(Jparser.Int (\d*)l\)\)\)', text
    ):
        length = int(m.group(1))
    else:
        raise MumbleException("could not find secret_length in output")

    # [("1", "123"), ("2", "-456"), ...]
    matches = re.findall(
        r'\("secret_(\d*)", "I"\), ref \(\(Jparser.Int (-?\d*)l\)\)\)', text
    )
    matches = [(int(i), int(v)) for i, v in matches]

    # sort by index
    ints = sorted(matches, key=lambda e: e[0])
    ints = [v for _, v in ints]

    return ints_to_flag(ints, length)


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
    assert_equals(reconstruct_flag(r.text), task.flag, "flag not found")


@checker.exploit(0)
async def exploit_test(searcher: FlagSearcher, client: AsyncClient) -> Optional[str]:
    r = await client.get(
        "/note/*",
    )
    assert not r.is_error

    if flag := searcher.search_flag(r.text):
        return flag
