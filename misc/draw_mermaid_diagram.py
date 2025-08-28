import sys
import re
import os
import asyncio

from pyppeteer import launch


HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <script>
{mermaid_js}
  </script>
  <style>
    body {{ margin: 0; padding: 20px; }}
    #diagram {{ width: 100%%; height: 100%%; }}
  </style>
</head>
<body>
  <div id="diagram"></div>
  <script>
    (async () => {{
      try {{
        mermaid.initialize({{ theme: 'default' }});
        const {{ svg }} = await mermaid.render('svg', `{code}`);
        document.getElementById('diagram').innerHTML = svg;
      }} catch (e) {{ console.error(e); }}
    }})();
  </script>
</body>
</html>
"""

def load_mermaid_code(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取 ```mermaid ... ``` 块
    match = re.search(r'```mermaid\s*([\s\S]*?)```', content, re.IGNORECASE | re.DOTALL)
    if match:
        return match.group(1).strip()
    else:
        # 如果是纯 .mmd 文件，直接返回全文
        return content.strip()

def validate_mermaid_syntax(code):
    # 简单检查是否以 graph、flowchart 等开头
    valid_starts = ['graph', 'flowchart', 'sequenceDiagram', 'classDiagram', 'stateDiagram']
    stripped = code.strip()
    if not any(stripped.startswith(kw) for kw in valid_starts):
        print("⚠️  Warning: Mermaid code may have invalid syntax")
        print(code)
    return stripped


# 2. 用 Pyppeteer 渲染并截图
async def mermaid_to_png(mermaid_code, output_png='mermaid_output.png'):
    browser = await launch(headless=True, args=[
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--allow-file-access-from-files'
    ])
    page = await browser.newPage()
    # 启用日志
    page.on('console', lambda msg: print('PAGE LOG:', msg.text))
    page.on('error', lambda err: print('PAGE ERROR:', err))
    page.on('pageerror', lambda err: print('PAGE UNHANDLED ERROR:', err))

    MERMAID_JS = ''
    with open("mermaid.min.js", "r", encoding="utf-8") as f:
        MERMAID_JS = f.read()
    html = HTML_TEMPLATE.format(mermaid_js=MERMAID_JS, code=mermaid_code)

    # 设置页面内容
    await page.setContent(html)

    # 等待渲染完成（mermaid 渲染需要一点时间）
    await page.waitForFunction('!!document.querySelector("#diagram svg")', timeout=5000)

    # 获取 SVG 元素截图
    diagram = await page.querySelector('#diagram')
    await diagram.screenshot({'path': output_png})

    print(f"✅ Saved diagram to {output_png}")
    await browser.close()

async def main():
    mmd_path = sys.argv[1]
    print(f'Loading mermaid code from {mmd_path}')
    code = load_mermaid_code(mmd_path)  # 或 'README.md'
    code = validate_mermaid_syntax(code)
    bname = os.path.splitext(os.path.basename(mmd_path))[0]
    output_filename = f'{bname}.png'
    print(f'Generating image...')
    await mermaid_to_png(code, output_filename)
    print(f'Output path: {output_filename}')

if __name__ == '__main__':
    # Windows 上需要处理 asyncio 事件循环
    import sys
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    asyncio.run(main())
