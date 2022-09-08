import httpx
import asyncio
from datetime import datetime
import click

async def get_async(url):
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url)
            if resp.status_code >= 200:
                print(url + " is accessible, return code: " + str(resp.status_code))
            return resp.status_code, url
        except:
            return None
        

urls = [url for i in range(2,255) for url in [f"http://192.168.1.{i}/"]]

async def launch():
    resps = await asyncio.gather(*map(get_async, urls))
    # for resp in resps:
    #     print(resp)
    

if __name__ == "__main__":
    start = datetime.now()
    asyncio.run(launch())
    end = datetime.now()
    click.secho(f"Time taken: {end - start}", fg="green")
