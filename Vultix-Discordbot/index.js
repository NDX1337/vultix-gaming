const Discord = require("discord.js");
const client = new Discord.Client();
const bot1 = new Discord.Client();
const bot2 = new Discord.Client();
var MTA = require('mtasa-sdk');
const { Sequelize, Model, DataTypes, Op } = require('sequelize');
let serversInfo = [];
let mtaServers = [];
let serverPorts = [22006, 22009, 22012, 22015, 22019, 22022, 22024, 22026, 22028, 22030, 22032, 22034];
for (let i = 0; i < serverPorts.length; i++) {
    serversInfo[i] = {players: 0, cwData: {status: "Free", teams: "AZ vs ??", score: "0 : 0"}}
    mtaServers[i] = new MTA('127.0.0.1', serverPorts[i], 'http_admin', 'be$tp4Ssvv0rd');
}
let totalOnline = 0;
var latestEmbed1, latestEmbed2, panelChannel1, panelChannel2, panelMsg1, panelMsg2;
const channelIDs = ["850372929472167987", "850372901974835250", "850372881946116176", "850372854218227732", "850367604279607297", "850302051649060864", "858834489420677121", "858834510011826227", "883157425010638898", "883157572079718410", "926118842466455552", "926118876801036319"]
const serverChannels = [];

const sequelize = new Sequelize('database', 'user', 'password', {
	host: 'localhost',
	dialect: 'sqlite',
	logging: false,
	// SQLite only
	storage: 'database.sqlite',
});

var User = sequelize.define('User', {
	userID: { type: DataTypes.STRING },
	mention: { type: DataTypes.STRING },
}, { timestamps: false });

client.on('ready', async () => {
    console.log(`Successfully logged in as ${client.user.tag}!`)
    await User.sync({ alter: true });
    cwScoresChannel = await client.channels.fetch("852580413024895027", false);
    reportChannel = await client.channels.fetch("876060455838285834", false);
});

bot1.on('ready', async () => {
    console.log(`Successfully logged in as ${bot1.user.tag}!`)
    panelChannel1 = await bot1.channels.fetch("852580470255910983", false);
    panelMsg1 = await panelChannel1.messages.fetch("891319811303411772", false);
    latestEmbed1 = getEmbedFromData(1);
    panelMsg1.edit(latestEmbed1)
    for (let i = 0; i < 6; i++) {
        serverChannels[i] = await bot1.channels.fetch(channelIDs[i], false);
        mtaServers[i].call('ae-sync', 'handleDiscordBotStart', []);
    }
})

bot2.on('ready', async () => {
    console.log(`Successfully logged in as ${bot2.user.tag}!`)
    panelChannel2 = await bot2.channels.fetch("852580470255910983", false);
    panelMsg2 = await panelChannel2.messages.fetch("891320025191944232", false);
    latestEmbed2 = getEmbedFromData(2);
    panelMsg2.edit(latestEmbed2)
    for (let i = 6; i < serverPorts.length; i++) {
        serverChannels[i] = await bot2.channels.fetch(channelIDs[i], false);
        mtaServers[i].call('ae-sync', 'handleDiscordBotStart', []);
    }
})

function getEmbedFromData(num) {
    let myEmbed = new Discord.MessageEmbed();
    if (num == 1) {
        for (let i = 0; i < 6; i++) {
            myEmbed.addField(`Server ${i+1}`, `${serversInfo[i].players} Online.${i !== serverPorts.length-1? "\n\u200b": ""}`, true);
            myEmbed.addField(`Teams`, serversInfo[i].cwData.teams, true);
            myEmbed.addField(`Status`, `(${serversInfo[i].cwData.status}) ${serversInfo[i].cwData.score}`, true);
            // if (i !== serverPorts.length-1) {
            //     myEmbed.addField('\u200b', '\u200b', false);
            // }
        }
    } else {
        for (let i = 6; i < serverPorts.length; i++) {
            myEmbed.addField(`Server ${i+1}`, `${serversInfo[i].players} Online.${i !== serverPorts.length-1? "\n\u200b": ""}`, true);
            myEmbed.addField(`Teams`, serversInfo[i].cwData.teams, true);
            myEmbed.addField(`Status`, `(${serversInfo[i].cwData.status}) ${serversInfo[i].cwData.score}`, true);
            // if (i !== serverPorts.length-1) {
            //     myEmbed.addField('\u200b', '\u200b', false);
            // }
        }
    }
    return myEmbed;
}

client.on("message", async (message) => {
    if (message.author.bot) return;
    let myIndex = channelIDs.findIndex(e => e == message.channel.id)
    if (myIndex != -1) {
        let myTable = message.content.split(" ");
        if (myTable[0] != "/setmention") {
            mtaServers[myIndex].call('ae-sync', 'onDiscordMessage', [message.member.displayName, message.member.roles.cache.map(role => role.id), message.content]);
        } else {
            let nickNameUsed = await User.findOne({where: {mention: myTable[1].toLowerCase()}});
            if (!nickNameUsed) {
                let user = await User.findOne({where: {userID: message.author.id}});
                if (user) {
                    user.mention = myTable[1].toLowerCase();
                    await user.save();
                } else {
                    await User.create({userID: message.author.id, mention: myTable[1].toLowerCase()})
                }
                message.react("✅");
            } else {
                message.channel.send("This mention is already used!")
            }
        }
    }
})

client.login("ODU0Njg1NDgwMTEyNDg4NDc4.YMnh4Q.V-BlC4MDdu23ri3FN9ZazObmod0");
bot1.login("ODkxMzA2NDU2NTM4ODI4ODgx.YU8b0g.5Nz7gtUjiSRW6hOh7YBUC3uREdk");
bot2.login("ODkxMzA2NTE3NTI0MDE3MTgy.YU8b4Q.-STYH2JkQG9TRt1PCvoqsyEErKQ");


var express = require('express');
var multer = require('multer');
var app = express();
var upload = multer();
app.use(upload.array()); 
app.use(express.static('public'));
shouldUpdate1 = false
shouldUpdate2 = false
var updateCount = true;

app.post('/', async function (req, res) {
    if (req.body) {
        if (req.body.type) {
            if (req.body.type == "count") {
                serversInfo[Number(req.body.server)-1].players = req.body.count;
                if (Number(req.body.server) <= 6) {
                    latestEmbed1 = getEmbedFromData(1);
                    shouldUpdate1 = true;
                } else {
                    latestEmbed2 = getEmbedFromData(2);
                    shouldUpdate2 = true;
                }
                updateTotalCount();
                updateCount = true;
            } else if (req.body.type == "cw") {
                serversInfo[Number(req.body.server)-1].cwData = JSON.parse(req.body.cwData);
                if (Number(req.body.server) <= 6) {
                    latestEmbed1 = getEmbedFromData(1);
                    shouldUpdate1 = true;
                } else {
                    latestEmbed2 = getEmbedFromData(2);
                    shouldUpdate2 = true;
                }
            } else if (req.body.type == "score") {
                let scoreData = JSON.parse(req.body.scoreData);
                let title = scoreData[0].name+" "+scoreData[0].points+"-"+scoreData[1].points+" "+scoreData[1].name;
				let description = "<:green:880532676405248070>**"+scoreData[0].name+"** has won against **"+scoreData[1].name+"** with a score of **( "+scoreData[0].points+" : "+scoreData[1].points+" )**";
                if (scoreData[0].points == scoreData[1].points) {
                    description = scoreData[0].name+" vs "+scoreData[1].name+" ended with a draw with score **( "+scoreData[0].points+" : "+scoreData[1].points+" )**";
                }
                if (!scoreData[0].players || !scoreData[1].players) {
                    return false;
                }
                let myEmbed = new Discord.MessageEmbed()
					.setAuthor(`${title}`,`https://www.designfreelogoonline.com/wp-content/uploads/2018/06/01001-modern-V-Logo-02.png`)
                    .setDescription(description)
                    .addField("<:win:880532726523002880>"+scoreData[0].name+" player list", scoreData[0].players, true)
                    .addField("<:lose:880532746643071016>"+scoreData[1].name+" player list", scoreData[1].players, true)
                    .addField("Top Kills", req.body.killsData, false)
					.setImage(`https://cdn.discordapp.com/attachments/870726093554995281/880836598047051867/vultix_gaming_banner_dark_theme.png`)
					.setFooter(`Vultix Gaming Server ${req.body.server} ©`,`https://www.designfreelogoonline.com/wp-content/uploads/2018/06/01001-modern-V-Logo-02.png`)
					.setTimestamp();
                try {
                    await cwScoresChannel.send(myEmbed);
                }
                catch(err){}
            } else if (req.body.type == "report") {
                reportChannel.send(req.body.message +"\n<@&840510463917555722>  <@&917806121337647124> <@&904314092532150282>")
            }
        }
    }
    res.end();
});

app.post('/chat', async function (req, res) {
    if (req.body && req.body.message) {
        let myTable = req.body.message.split(" ")
        for (let i = 0; i < myTable.length; i++) {
            if (myTable[i][0] == "@") {
                if (myTable[i] == "@everyone") {
                    continue;
                }
                myTable[i] = myTable[i].substr(1).toLowerCase();
                let myUser = await User.findOne({where: {mention: myTable[i]}});
                if (myUser) {
                    myTable[i] = `<@${myUser.userID}>`;
                    req.body.message = myTable.join(" ")
                }
            }
        }
        try {
            await serverChannels[Number(req.body.server)-1].send(req.body.message, {disableMentions: 'everyone'})
        }
        catch(err){}
    }
    res.end();
});

var server = app.listen(5555, function () {
   var host = server.address().address
   var port = server.address().port
   console.log("Example app listening at http://%s:%s", host, port)
});

function updateTotalCount() {
    let number = 0;
    for (const server of serversInfo) {
        number += Number(server.players)
    }
    totalOnline = number;
}

setInterval(async function() {
    if (shouldUpdate1) {
        if (panelMsg1 && panelMsg1.embeds) {
            try {
                await panelMsg1.edit(latestEmbed1);
                shouldUpdate1 = false;
            }
            catch(err){

            }
        }
    }
}, 2500)

setInterval(async function() {
    if (shouldUpdate2) {
        if (panelMsg2 && panelMsg2.embeds) {
            try {
                await panelMsg2.edit(latestEmbed2);
                shouldUpdate2 = false;
            }
            catch(err){

            }
        }
    }
}, 2500)


setInterval(function() {
    if (updateCount) {
        client.user.setActivity(`${totalOnline} players online.`, {type: 'WATCHING'});
        updateCount = false;
    }
}, 4000)