import httpx

with open("ABD.class", "rb") as f:
    data = f.read()

    files = {"fileToUpload": ("ABD.class", data)}
    r = httpx.post("http://localhost:3165/runner.php", files=files)
    print(r)
    print(r.text)
