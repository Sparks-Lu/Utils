// Prepare:
//  install node.js
//  cnpm i -S puppeteer
// Run:
//  node ./website_screenshot.js
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setViewport({
    width: 1920,
    height: 1080,
    deviceScaleFactor: 1,
  })
  await page.goto('https://fishpano.com');

  let date_ob = new Date();
  // adjust 0 before single digit date
  let date = ("0" + date_ob.getDate()).slice(-2);
  let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
  let year = date_ob.getFullYear();
  let hours = date_ob.getHours();
  let minutes = date_ob.getMinutes();
  let seconds = date_ob.getSeconds();
  let timestamp = year + month + date + hours + minutes + seconds;

  await page.screenshot({ path: 'fishpano_' + timestamp + '.jpg' });

  await browser.close();
})();
