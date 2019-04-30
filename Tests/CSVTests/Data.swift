let orderedData: OrderedKeyedCollection = [
    "first name": ["Caleb", "Benjamin", "Doc", "Grace", "Anne", "TinTin"],
    "last_name": ["Kleveter", "Franklin", "Holliday", "Hopper", "Shirley", nil],
    "age": ["18", "269", "174", "119", "141", "16"],
    "gender": ["M", "M", "M", "F", "F", "M"],
    "tagLine": [
        "😜", "A penny saved is a penny earned", "Bang", nil,
        "God's in His heaven,\nall's right with the world", "Great snakes!"
    ]
]

let orderedChunks: [OrderedKeyedCollection<String, Array<String?>>] = [
    ["first name": ["Caleb"], "last_name": ["Kleveter"], "age": ["18"], "gender": ["M"], "tagLine": ["😜"]],
    [
        "first name": ["Benjamin"], "last_name": ["Franklin"], "age": ["269"], "gender": ["M"],
        "tagLine": ["A penny saved is a penny earned"]
    ],
    ["first name": ["Doc"], "last_name": ["Holliday"], "age": ["174"], "gender": ["M"], "tagLine": ["Bang"]],
    ["first name": ["Grace"], "last_name": ["Hopper"], "age": ["119"], "gender": ["F"], "tagLine": [nil]],
    [
        "first name": ["Anne"], "last_name": ["Shirley"], "age": ["141"], "gender": ["F"],
        "tagLine": ["God's in His heaven,\nall's right with the world"]
    ],
    ["first name": ["TinTin"], "last_name": [nil], "age": ["16"], "gender": ["M"], "tagLine": ["Great snakes!"]]
]

let chunks: [String] = [
    "first name,last_name,age",
    ",gender,tagLine\nCaleb,Kleveter,18,M,",
    "😜\r\nBenjamin,Franklin,269,M,A penny saved is a ",
    "penny earned\n\"",
    #"Doc","Holliday","174","M",Bang\#r\#n"#,
    "Grace,Hopper,119,F,",
    #"\#nAnne,Shirley,141,F,"God's in His heaven,\#n"#,
    #"all's right with the world""#,
    "\nTinTin,,16,M,Great snakes!"
]

let data = """
first name,last_name,age,gender,tagLine
Caleb,Kleveter,18,M,😜\r
Benjamin,Franklin,269,M,A penny saved is a penny earned
"Doc","Holliday","174","M",Bang\r
Grace,Hopper,119,F,
Anne,Shirley,141,F,"God's in His heaven,
all's right with the world"
TinTin,,16,M,Great snakes!
"""

let expected = """
"first name","last_name","age","gender","tagLine"
"Caleb","Kleveter","18","M","😜"
"Benjamin","Franklin","269","M","A penny saved is a penny earned"
"Doc","Holliday","174","M","Bang"
"Grace","Hopper","119","F",""
"Anne","Shirley","141","F","God's in His heaven,
all's right with the world"
"TinTin","","16","M","Great snakes!"
"""
