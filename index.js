const fs = require("fs");
const dasha = require("@dasha.ai/sdk");
const axios = require("axios").default;


async function main() {
  const app = await dasha.deploy("./app");
  app.setExternal("confirm", async(args, conv) => {
      console.log("collected signal is " + args.signal);
    if (args.signal == "Maverick")
      return true;
    else 
      return false; 
  });

  

  await app.start();

  const conv = app.createConversation({ phone: process.argv[2] ?? "" });

  conv.audio.tts = "dasha";

   if (conv.input.phone === "chat") {
     await dasha.chat.createConsoleChat(conv);
   } else {
     conv.on("transcription", console.log);
   }

  const logFile = await fs.promises.open("./log.txt", "w");
  await logFile.appendFile("#".repeat(100) + "\n");

  conv.on("transcription", async (entry) => {
    await logFile.appendFile(`${entry.speaker}: ${entry.text}\n`);
  });

  conv.on("debugLog", async (event) => {
    if (event?.msg?.msgId === "RecognizedSpeechMessage") {
      const logEntry = event?.msg?.results[0]?.facts;
      await logFile.appendFile(JSON.stringify(logEntry, undefined, 2) + "\n");
    }
  });

  const result = await conv.execute({
     channel: conv.input.phone === "chat" ? "text" : "audio",
   });

  console.log(result.output);

  await app.stop();
  app.dispose();

  await logFile.close();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

