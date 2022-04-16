import std/[httpclient, strutils, strformat, os]

const startStr = "<tbody><tr><td class=\"link\"><a href=\"../\">Parent directory/</a></td><td class=\"size\">-</td><td class=\"date\">-</td></tr>"
const stopStr = "</tbody></table></main>"

const debug = true

var client = newHttpClient()

proc cDragonDownloadPage(url, output: string, sleep: int = 10) = 
  let page = client.getContent(url)
  let start = page.find(startStr)
  let stop = page.find(stopStr)
  let lines = page[start+startStr.len() + 2..<stop]

  for line in lines.splitLines():
    let leftSplit = line.split("<a href=\"")

    if leftSplit.len() < 2: continue
    let name = leftSplit[1].split("\" title=\"")[0]
    # skip folders
    if name.endsWith("/"): continue

    let pngData = 
      try: 
        client.getContent(fmt"{url}{name}") 
      except:
        if debug: echo "Got exception ", repr(getCurrentException()), " with message ", getCurrentExceptionMsg()
        continue

    writeFile(fmt"{output}{name}", pngData)
    if debug: echo fmt("Downloaded: {output}{name:<60} From: {url}{name}")
    sleep(sleep)



cDragonDownloadPage("https://raw.communitydragon.org/latest/game/data/spells/icons2d/", "assets/icons/spells/")
cDragonDownloadPage("https://raw.communitydragon.org/latest/plugins/rcp-fe-lol-parties/global/default/", "assets/icons/party/")