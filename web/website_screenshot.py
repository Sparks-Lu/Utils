import asyncio
import pyppeteer


async def main():
    browser = await pyppeteer.launch()
    page = await browser.newPage()
    await page.goto('https://fishpano.com/')
    await page.screenshot({'path': 'fishpano.png'})
    await browser.close()
asyncio.get_event_loop().run_until_complete(main())
