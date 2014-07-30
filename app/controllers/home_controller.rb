#encoding: utf-8
class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    params[:search] = nil if params[:search] and params[:search].strip == "" 
    @page = params[:page] || 0
    all_entries = (params[:search] ? Entry.search(params[:search]) : Entry).order("romaji_order")
    @count = all_entries.count
    @entries = all_entries.page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entries }
    end
  end

  LEMMATA = {"Heilsfiguren"=>[["1222:5", 8627, "仏", "butsu"], ["1295:2", 8964, "菩薩", "bosatsu"], ["1124:5", 8081, "如来", "nyorai"], ["28:1", 1187, "阿羅漢", "arakan"], ["1374:5", 9377, "明王", "myōō"], ["1020:1", 7489, "天", "ten"], ["744:4", 5972, "聖人", "shōnin"], ["1185:3", 8417, "聖", "hijiri"]], "Ontologie / Weltbild"=>[["", "", "六道", "rokudō"], ["491:3", 4343, "三世", "sanze"], ["468:2", 4227, "三界", "sangai"], ["522:3", 4510, "色界", "shikikai"], ["1394:1", 9522, "無色界", "mushikikai"], ["1395:5", 9530, "無常", "mujō"], ["65:3", 1484, "因果経", "inga"], ["125:7", 1791, "縁起", "engi"], ["687:1", 5533, "性", "shō"], ["51:3", 1377, "一如", "ichinyo"], ["801:2", 6367, "真如", "shinnyo"], ["1244:5", 8672, "不二", "funi"], ["279:6", 2892, "空", "kū"], ["1388:4", 9489, "無", "mu"], ["1174:2", 8382, "般若", "hannya"], ["838:5", 6624, "禅", "zen"], ["687:6", 5538, "定", "jō"], ["86:5", 1588, "有情", "ujō"], ["", "", "無情", "mujō"], ["668:6", 5384, "衆生", "shujō"], ["519:7", 4504, "色", "shiki"], ["871:2", 6828, "相", "sō"], ["254:8", 2692, "行", "gyō"], ["20:1", 1134, "識", "shiki"], ["871:3", 6829, "想", "sō"], ["392:4", 3699, "五慍", "goun, goon"], ["236:4", "", "機", "ki"], ["237:1", 2536, "義", "gi"], ["1037:2", 865, "道", "dō"], ["689:1", 5539, "乗", "jō"], ["1259:6", 8754, "法", "hō"], ["254:3", 2687, "教", "kyō"], ["254:8", 2692, "行", "gyō"], ["660:5", 5330, "修行", "shugyō"], ["295:4", 3014, "功徳", "kudoku"], ["1397:8", 9557, "無明", "mumyō"], ["1336:2", 9173, "煩悩", "bonnō"], ["1340:3", 9179, "凡夫", "bonpu"], [">236:3", "", "器", "ki"], ["474:6", 4259, "懺悔", "sange, zange"], ["359:11", 3493, "悟", "go, satori"], ["177:4", 2083, "覚", "kaku, satori"], ["687: 3", "", "証", "shō"], ["747:5", 6004, "成仏", "jōbutsu"], ["1228:1", 8639, "仏性", "busshō"], ["1125:4", 8085, "如来蔵", "nyoraizō"], ["1132:3", 8128, "涅槃", "nehan"], ["324:9", 3226, "解脱", "gedatsu"], ["513:2", 4464, "寺院", "jiin"], ["", "", "山号", "sangō"], ["1326:6", 9119, "本山", "honzan"], ["405:4", 3786, "五山", "gozan"], ["", "", "末寺", "matsuji"], ["", "", "僧", "sō"], ["22:8", 1157, "尼", "ama, ni"], ["474:4", 4257, "山家", "sange"], ["873:3", 6836, "僧位", "sōi"], ["848:4", 6681, "禅師", "zenji"], ["886:1", 6934, "僧職", "sōshoku"], ["1255:9", 8734, "別当", "bettō"], ["1420:2", 9711, "山伏", "yamabushi"], ["888:6", 6941, "僧都", "sōzu"], ["", "", "住職", "jūshoku"], ["987:2", 249, "知事", "chishiki"], ["1453:5", 9922, "律師", "risshi"], ["", "", "論師", "ronshi"], ["", "", "三蔵", "sanzō"], ["", "", "権僧正", "gonsōjō"], ["254:4", 2688, "経", "kyō"], ["", "", "偽経", "gikyō"], ["1506:3", 10275, "論", "ron"], ["1449:9", 9917, "律", "ritsu"], ["175:3", 2062, "戒律", "kairitsu"], ["", "", "因果経", "ingakyō"], ["1384:1", 9454, "法華経", "hokkekyō"], ["317:2", 3177, "華厳経", "kegonkyō"], ["1175:1", 8385, "般若経", "hannyakyō"], ["1133:2", 8130, "涅槃経", "nehangyō"], ["", "", "伝", "den"], ["379:3", 3619, "高僧伝", "kōsōden"], ["431:3", 3947, "語録", "goroku"], ["1361:5", 9312, "曼荼羅", "mandara"], ["928:3", 7187, "大乗", "daijō"], ["1421:7", 9724, "唯識", "yuishiki"], ["1026:6", 7529, "天台", "tendai"], ["321:1", 3198, "華厳", "kegon"], ["737:1", 5919, "浄土", "jōdo"], ["784:4", 6255, "真言", "shingon"], ["850:3", 6693, "禅", "zen"], ["510:2", 4448, "三論", "sanron"], ["1453:7", 9924, "律宗", "risshū"], ["719:1", 5778, "小乗", "shōjō"], ["1261:8", 8767, "法会", "hōe"], ["372:7", 3563, "講式", "kōshiki"], ["463:5", 4186, "座禅", "zazen"], ["518:7", 4497, "止観", "shikan"], ["28:2", 1188, "荒行", "aragyō"]], "Philosophie / Epistemologie"=>[["51:3", 1377, "一如", "ichinyo"], ["801:2", 6367, "真如", "shinnyo"], ["1244:5", 8672, "不二", "funi"], ["279:6", 2892, "空", "kū"], ["1388:4", 9489, "無", "mu"], ["1174:2", 8382, "般若", "hannya"], ["838:5", 6624, "禅", "zen"], ["687:6", 5538, "定", "jō"], ["86:5", 1588, "有情", "ujō"], ["", "", "無情", "mujō"], ["668:6", 5384, "衆生", "shujō"], ["519:7", 4504, "色", "shiki"], ["871:2", 6828, "相", "sō"], ["254:8", 2692, "行", "gyō"], ["20:1", 1134, "識", "shiki"], ["871:3", 6829, "想", "sō"], ["392:4", 3699, "五慍", "goun, goon"], ["236:4", "", "機", "ki"], ["237:1", 2536, "義", "gi"], ["1037:2", 865, "道", "dō"], ["689:1", 5539, "乗", "jō"], ["1259:6", 8754, "法", "hō"], ["254:3", 2687, "教", "kyō"], ["254:8", 2692, "行", "gyō"], ["660:5", 5330, "修行", "shugyō"], ["295:4", 3014, "功徳", "kudoku"], ["1397:8", 9557, "無明", "mumyō"], ["1336:2", 9173, "煩悩", "bonnō"], ["1340:3", 9179, "凡夫", "bonpu"], [">236:3", "", "器", "ki"], ["474:6", 4259, "懺悔", "sange, zange"], ["359:11", 3493, "悟", "go, satori"], ["177:4", 2083, "覚", "kaku, satori"], ["687: 3", "", "証", "shō"], ["747:5", 6004, "成仏", "jōbutsu"], ["1228:1", 8639, "仏性", "busshō"], ["1125:4", 8085, "如来蔵", "nyoraizō"], ["1132:3", 8128, "涅槃", "nehan"], ["324:9", 3226, "解脱", "gedatsu"], ["513:2", 4464, "寺院", "jiin"], ["", "", "山号", "sangō"], ["1326:6", 9119, "本山", "honzan"], ["405:4", 3786, "五山", "gozan"], ["", "", "末寺", "matsuji"], ["", "", "僧", "sō"], ["22:8", 1157, "尼", "ama, ni"], ["474:4", 4257, "山家", "sange"], ["873:3", 6836, "僧位", "sōi"], ["848:4", 6681, "禅師", "zenji"], ["886:1", 6934, "僧職", "sōshoku"], ["1255:9", 8734, "別当", "bettō"], ["1420:2", 9711, "山伏", "yamabushi"], ["888:6", 6941, "僧都", "sōzu"], ["", "", "住職", "jūshoku"], ["987:2", 249, "知事", "chishiki"], ["1453:5", 9922, "律師", "risshi"], ["", "", "論師", "ronshi"], ["", "", "三蔵", "sanzō"], ["", "", "権僧正", "gonsōjō"], ["254:4", 2688, "経", "kyō"], ["", "", "偽経", "gikyō"], ["1506:3", 10275, "論", "ron"], ["1449:9", 9917, "律", "ritsu"], ["175:3", 2062, "戒律", "kairitsu"], ["", "", "因果経", "ingakyō"], ["1384:1", 9454, "法華経", "hokkekyō"], ["317:2", 3177, "華厳経", "kegonkyō"], ["1175:1", 8385, "般若経", "hannyakyō"], ["1133:2", 8130, "涅槃経", "nehangyō"], ["", "", "伝", "den"], ["379:3", 3619, "高僧伝", "kōsōden"], ["431:3", 3947, "語録", "goroku"], ["1361:5", 9312, "曼荼羅", "mandara"], ["928:3", 7187, "大乗", "daijō"], ["1421:7", 9724, "唯識", "yuishiki"], ["1026:6", 7529, "天台", "tendai"], ["321:1", 3198, "華厳", "kegon"], ["737:1", 5919, "浄土", "jōdo"], ["784:4", 6255, "真言", "shingon"], ["850:3", 6693, "禅", "zen"], ["510:2", 4448, "三論", "sanron"], ["1453:7", 9924, "律宗", "risshū"], ["719:1", 5778, "小乗", "shōjō"], ["1261:8", 8767, "法会", "hōe"], ["372:7", 3563, "講式", "kōshiki"], ["463:5", 4186, "座禅", "zazen"], ["518:7", 4497, "止観", "shikan"], ["28:2", 1188, "荒行", "aragyō"]], "Soteriologie"=>[["1037:2", 865, "道", "dō"], ["689:1", 5539, "乗", "jō"], ["1259:6", 8754, "法", "hō"], ["254:3", 2687, "教", "kyō"], ["254:8", 2692, "行", "gyō"], ["660:5", 5330, "修行", "shugyō"], ["295:4", 3014, "功徳", "kudoku"], ["1397:8", 9557, "無明", "mumyō"], ["1336:2", 9173, "煩悩", "bonnō"], ["1340:3", 9179, "凡夫", "bonpu"], [">236:3", "", "器", "ki"], ["474:6", 4259, "懺悔", "sange, zange"], ["359:11", 3493, "悟", "go, satori"], ["177:4", 2083, "覚", "kaku, satori"], ["687: 3", "", "証", "shō"], ["747:5", 6004, "成仏", "jōbutsu"], ["1228:1", 8639, "仏性", "busshō"], ["1125:4", 8085, "如来蔵", "nyoraizō"], ["1132:3", 8128, "涅槃", "nehan"], ["324:9", 3226, "解脱", "gedatsu"]], "Institutionen, Ämter, Titel"=>[["513:2", 4464, "寺院", "jiin"], ["", "", "山号", "sangō"], ["1326:6", 9119, "本山", "honzan"], ["405:4", 3786, "五山", "gozan"], ["", "", "末寺", "matsuji"], ["", "", "僧", "sō"], ["22:8", 1157, "尼", "ama, ni"], ["474:4", 4257, "山家", "sange"], ["873:3", 6836, "僧位", "sōi"], ["848:4", 6681, "禅師", "zenji"], ["886:1", 6934, "僧職", "sōshoku"], ["1255:9", 8734, "別当", "bettō"], ["1420:2", 9711, "山伏", "yamabushi"], ["888:6", 6941, "僧都", "sōzu"], ["", "", "住職", "jūshoku"], ["987:2", 249, "知事", "chishiki"], ["1453:5", 9922, "律師", "risshi"], ["", "", "論師", "ronshi"], ["", "", "三蔵", "sanzō"], ["", "", "権僧正", "gonsōjō"]], "Lehre und Texte"=>[["254:4", 2688, "経", "kyō"], ["", "", "偽経", "gikyō"], ["1506:3", 10275, "論", "ron"], ["1449:9", 9917, "律", "ritsu"], ["175:3", 2062, "戒律", "kairitsu"], ["", "", "因果経", "ingakyō"], ["1384:1", 9454, "法華経", "hokkekyō"], ["317:2", 3177, "華厳経", "kegonkyō"], ["1175:1", 8385, "般若経", "hannyakyō"], ["1133:2", 8130, "涅槃経", "nehangyō"], ["", "", "伝", "den"], ["379:3", 3619, "高僧伝", "kōsōden"], ["431:3", 3947, "語録", "goroku"], ["1361:5", 9312, "曼荼羅", "mandara"]], "Schulen und Richtungen"=>[["928:3", 7187, "大乗", "daijō"], ["1421:7", 9724, "唯識", "yuishiki"], ["1026:6", 7529, "天台", "tendai"], ["321:1", 3198, "華厳", "kegon"], ["737:1", 5919, "浄土", "jōdo"], ["784:4", 6255, "真言", "shingon"], ["850:3", 6693, "禅", "zen"], ["510:2", 4448, "三論", "sanron"], ["1453:7", 9924, "律宗", "risshū"], ["719:1", 5778, "小乗", "shōjō"]], "Rituale, Meditation"=>[["1261:8", 8767, "法会", "hōe"], ["372:7", 3563, "講式", "kōshiki"], ["463:5", 4186, "座禅", "zazen"], ["518:7", 4497, "止観", "shikan"], ["28:2", 1188, "荒行", "aragyō"]]}

  def hundredlemma
    @lemmata = LEMMATA
    respond_to do |format|
      format.html # hundredlemma.html.erb
      format.json { render json: @lemmata }
    end
  end
end
