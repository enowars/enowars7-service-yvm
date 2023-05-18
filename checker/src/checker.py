import secrets
import string
from typing import Optional

from httpx import AsyncClient

from enochecker3 import (
    ChainDB,
    Enochecker,
    GetflagCheckerTaskMessage,
    MumbleException,
    PutflagCheckerTaskMessage,
)
from enochecker3.utils import FlagSearcher, assert_equals, assert_in

checker = Enochecker("Yvm", 3165)
app = lambda: checker.app


@checker.putflag(0)
async def putflag_test(
    task: PutflagCheckerTaskMessage,
    client: AsyncClient,
    db: ChainDB,
) -> None:
    assert_equals(1, 2, "foo")
    token = secrets.randbits(31)
    class_name = ''.join(secrets.choice(string.ascii_uppercase) for i in range(5))
    with open('classes/NAME.java') as template:
        t = template.read()
        t = t.replace("NAME", class_name)
        t = t.replace("SECRET", str(token))

        files = {'fileToUpload': (f"{class_name}.class", t)}
        r = await client.post("/runner.php", files=files)
        print(r)
        print(r.text)
        assert_equals(r.status_code, 200, "storing class with flag failed")

        await db.set("replay_id", token)


@checker.getflag(0)
async def getflag_test(
    task: GetflagCheckerTaskMessage, client: AsyncClient, db: ChainDB
) -> None:
    try:
        token = await db.get("token")
    except KeyError:
        raise MumbleException("Missing database entry from putflag")

    r = await client.get(f"/note/{token}")
    assert_equals(r.status_code, 200, "getting note with flag failed")
    assert_in(task.flag, r.text, "flag missing from note")


@checker.exploit(0)
async def exploit_test(searcher: FlagSearcher, client: AsyncClient) -> Optional[str]:
    r = await client.get(
        "/note/*",
    )
    assert not r.is_error

    if flag := searcher.search_flag(r.text):
        return flag
