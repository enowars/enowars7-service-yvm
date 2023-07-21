import httpx

files = {"fileToUpload": open("ABC.class", "rb")}
r = httpx.post("http://localhost:3165/runner.php", files=files)
print(r)
print(r.text)
