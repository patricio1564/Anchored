// Biblically accurate lesson content organized by topics
import { EXTRA_TOPICS } from './bibleContentExtra.js';
import { EXTRA_TOPICS_2 } from './bibleContentExtra2.js';

const BASE_TOPICS = [
  // ─── CREATION & GENESIS ───────────────────────────────────────────────────
  {
    id: "creation",
    title: "Creation & Genesis",
    description: "The beginning of all things",
    icon: "🌍",
    color: "from-emerald-500 to-teal-600",
    lessons: [
      {
        id: "creation-1",
        title: "In the Beginning",
        scripture: "Genesis 1:1-5",
        teaching: "In the beginning, God created the heavens and the earth. The earth was formless and empty, darkness was over the surface of the deep, and the Spirit of God was hovering over the waters. God said, 'Let there be light,' and there was light. God saw that the light was good, and He separated the light from the darkness. God called the light 'day,' and the darkness He called 'night.' And there was evening, and there was morning—the first day.",
        keyVerse: "In the beginning God created the heavens and the earth. — Genesis 1:1",
        questions: [
          { question: "What did God create first according to Genesis 1?", options: ["Light","Water","Animals","Man"], correct: 0, explanation: "Genesis 1:3 says 'Let there be light.' Light was the first thing God spoke into existence." },
          { question: "What was the state of the earth before God began creating?", options: ["Beautiful and lush","Formless and empty","Covered in ice","Full of animals"], correct: 1, explanation: "Genesis 1:2 describes the earth as 'formless and empty, darkness was over the surface of the deep.'" },
          { question: "Who was hovering over the waters?", options: ["Angels","The Spirit of God","Birds","Moses"], correct: 1, explanation: "Genesis 1:2 says 'the Spirit of God was hovering over the waters,' showing the Holy Spirit's presence at creation." }
        ]
      },
      {
        id: "creation-2",
        title: "The Six Days",
        scripture: "Genesis 1:6-31",
        teaching: "Over six days, God created the heavens and the earth with order and purpose. Day 2: He separated the waters and made the sky. Day 3: He gathered the waters and brought forth dry land and vegetation. Day 4: He made the sun, moon, and stars. Day 5: He created sea creatures and birds. Day 6: He made land animals and finally mankind—male and female—in His own image, giving them dominion over all the earth.",
        keyVerse: "So God created mankind in his own image, in the image of God he created them; male and female he created them. — Genesis 1:27",
        questions: [
          { question: "On which day did God create mankind?", options: ["Day 4","Day 5","Day 6","Day 7"], correct: 2, explanation: "Genesis 1:26-31 tells us God created man and woman on the sixth day." },
          { question: "In whose image was mankind created?", options: ["Angels' image","God's image","Animals' image","Their own image"], correct: 1, explanation: "Genesis 1:27 clearly states 'God created mankind in his own image.'" },
          { question: "What did God create on the fourth day?", options: ["Fish and birds","Land and plants","Sun, moon, and stars","Animals"], correct: 2, explanation: "Genesis 1:14-19 describes God creating the sun, moon, and stars on the fourth day." }
        ]
      },
      {
        id: "creation-3",
        title: "The Garden of Eden",
        scripture: "Genesis 2:7-25",
        teaching: "The Lord God formed the man from the dust of the ground and breathed into his nostrils the breath of life. He planted a garden eastward in Eden and placed the man there to work it and take care of it. God said, 'It is not good for the man to be alone,' so He caused Adam to fall into a deep sleep, took one of his ribs, and made a woman. Adam named her Eve, and they were both naked and felt no shame.",
        keyVerse: "Then the Lord God formed a man from the dust of the ground and breathed into his nostrils the breath of life. — Genesis 2:7",
        questions: [
          { question: "From what did God form Adam?", options: ["Water","Light","Dust of the ground","A tree"], correct: 2, explanation: "Genesis 2:7 says 'the Lord God formed a man from the dust of the ground and breathed into his nostrils the breath of life.'" },
          { question: "Why did God create Eve?", options: ["Adam asked for her","It was not good for man to be alone","To name the animals","To guard the garden"], correct: 1, explanation: "Genesis 2:18 says 'It is not good for the man to be alone. I will make a helper suitable for him.'" },
          { question: "Where did God place Adam?", options: ["Mount Sinai","Bethlehem","Garden of Eden","Jerusalem"], correct: 2, explanation: "Genesis 2:8 says God planted a garden in the east, in Eden, and put the man there." }
        ]
      },
      {
        id: "creation-4",
        title: "The Fall of Man",
        scripture: "Genesis 3:1-24",
        teaching: "The serpent tempted Eve by twisting God's command. Eve saw the fruit was pleasing and desirable, ate it, and gave some to Adam. Immediately their eyes were opened; they knew they were naked and hid from God. When confronted, Adam blamed Eve and Eve blamed the serpent. God pronounced curses on the serpent, the ground, and humanity—but also gave the first promise of a Redeemer in Genesis 3:15, called the Protoevangelium.",
        keyVerse: "And I will put enmity between you and the woman, and between your offspring and hers; he will crush your head, and you will strike his heel. — Genesis 3:15",
        questions: [
          { question: "Who tempted Eve in the garden?", options: ["An angel","A lion","The serpent","Another human"], correct: 2, explanation: "Genesis 3:1 introduces the serpent as 'more crafty than any of the wild animals the Lord God had made.'" },
          { question: "What did Adam and Eve do when they heard God walking?", options: ["Worshiped Him","Ran to greet Him","Hid from Him","Offered a sacrifice"], correct: 2, explanation: "Genesis 3:8 says 'they hid from the Lord God among the trees of the garden.'" },
          { question: "What is the significance of Genesis 3:15?", options: ["It describes the creation of animals","It is the first promise of a Redeemer","It names the garden","It establishes marriage"], correct: 1, explanation: "Genesis 3:15 is the Protoevangelium — the first gospel — promising that a descendant of Eve would crush the serpent's head." }
        ]
      },
      {
        id: "creation-5",
        title: "Noah and the Flood",
        scripture: "Genesis 6-9",
        teaching: "The earth became corrupt and filled with violence. God grieved that He had made humanity. But Noah found favor in God's eyes — he was righteous and blameless. God instructed Noah to build an ark and bring his family and two of every creature aboard. The flood covered the earth for forty days and nights. When the waters receded, God made a covenant with Noah never to destroy the earth by flood again, sealing it with a rainbow.",
        keyVerse: "But Noah found favor in the eyes of the Lord. — Genesis 6:8",
        questions: [
          { question: "Why did God send the flood?", options: ["To water the crops","Because the earth was corrupt and full of violence","To test Noah","To create the oceans"], correct: 1, explanation: "Genesis 6:11-12 says 'Now the earth was corrupt in God's sight and was full of violence.'" },
          { question: "How long did it rain?", options: ["7 days","14 days","40 days and nights","100 days"], correct: 2, explanation: "Genesis 7:12 says 'And rain fell on the earth forty days and forty nights.'" },
          { question: "What was the sign of God's covenant with Noah?", options: ["A dove","A star","A rainbow","An altar"], correct: 2, explanation: "Genesis 9:13 says 'I have set my rainbow in the clouds, and it will be the sign of the covenant.'" },
          { question: "How many people were saved on the ark?", options: ["2","7","8","12"], correct: 2, explanation: "1 Peter 3:20 confirms that eight people were saved through water — Noah, his wife, his three sons, and their wives." }
        ]
      },
      {
        id: "creation-6",
        title: "The Tower of Babel",
        scripture: "Genesis 11:1-9",
        teaching: "After the flood, all the earth had one language. People settled in a plain and decided to build a city and a tower that reached to the heavens to make a name for themselves and prevent being scattered. God came down, saw the city, and said that nothing would be impossible for them. He confused their language and scattered them across the earth. The city was called Babel, because there the Lord confused the language of the whole world.",
        keyVerse: "Come, let us go down and confuse their language so they will not understand each other. — Genesis 11:7",
        questions: [
          { question: "Why did the people want to build the Tower of Babel?", options: ["To worship God","To make a name for themselves and not be scattered","To store food","To observe stars"], correct: 1, explanation: "Genesis 11:4 says they wanted 'to make a name for ourselves; otherwise we will be scattered over the face of the whole earth.'" },
          { question: "How did God stop the building of the tower?", options: ["He destroyed it with fire","He flooded it","He confused their language","He sent an angel"], correct: 2, explanation: "Genesis 11:7 says God confused their language so they could not understand each other, stopping the construction." },
          { question: "What does the name 'Babel' mean?", options: ["Peace","High tower","Confusion","New beginning"], correct: 2, explanation: "Genesis 11:9 explains the city was called Babel 'because there the Lord confused the language of the whole world.'" }
        ]
      }
    ]
  },

  // ─── THE PATRIARCHS ───────────────────────────────────────────────────────
  {
    id: "patriarchs",
    title: "The Patriarchs",
    description: "Abraham, Isaac, Jacob & Joseph",
    icon: "⛺",
    color: "from-amber-500 to-orange-600",
    lessons: [
      {
        id: "patriarchs-1",
        title: "The Call of Abraham",
        scripture: "Genesis 12:1-9",
        teaching: "God called Abram to leave his country, his people, and his father's household to go to a land God would show him. God promised to make him into a great nation, to bless him, and to make his name great. Through Abraham, all peoples on earth would be blessed. Abram obeyed and departed, taking his wife Sarai and nephew Lot. He was seventy-five years old when he set out from Harran.",
        keyVerse: "I will make you into a great nation, and I will bless you; I will make your name great, and you will be a blessing. — Genesis 12:2",
        questions: [
          { question: "How old was Abram when he left Harran?", options: ["50","65","75","100"], correct: 2, explanation: "Genesis 12:4 states 'Abram was seventy-five years old when he set out from Harran.'" },
          { question: "What did God promise Abram?", options: ["Wealth only","A great nation and blessing","A palace","Victory in war"], correct: 1, explanation: "God promised to make Abram into a great nation, bless him, make his name great, and bless all peoples through him." },
          { question: "Who went with Abram on his journey?", options: ["Moses and Aaron","Sarai and Lot","Isaac and Jacob","No one"], correct: 1, explanation: "Genesis 12:5 says Abram took his wife Sarai and his nephew Lot with him." }
        ]
      },
      {
        id: "patriarchs-2",
        title: "God's Covenant with Abraham",
        scripture: "Genesis 15; 17",
        teaching: "God appeared to Abram in a vision and made a formal covenant with him. He told Abram to count the stars — so would his descendants be. Abram believed God, and it was credited to him as righteousness. God changed Abram's name to Abraham (father of many nations) and Sarai's name to Sarah. He instituted circumcision as the sign of the covenant. Though Abraham and Sarah were old far beyond childbearing age, God promised them a son named Isaac. This covenant pointed forward to the new covenant in Christ.",
        keyVerse: "Abram believed the Lord, and he credited it to him as righteousness. — Genesis 15:6",
        questions: [
          { question: "What did God use to illustrate the number of Abraham's descendants?", options: ["Grains of sand only","Stars of the sky","Blades of grass","Drops of water"], correct: 1, explanation: "Genesis 15:5 says God told Abram to look at the stars — 'so shall your offspring be.'" },
          { question: "What did God change Abram's name to?", options: ["Israel","Abraham","Isaac","Aaron"], correct: 1, explanation: "Genesis 17:5 says 'No longer will you be called Abram; your name will be Abraham, for I have made you a father of many nations.'" },
          { question: "What was the sign of God's covenant with Abraham?", options: ["A rainbow","A lamb sacrifice","Circumcision","The Sabbath"], correct: 2, explanation: "Genesis 17:10-11 establishes circumcision as the sign of the covenant between God and Abraham." }
        ]
      },
      {
        id: "patriarchs-3",
        title: "The Sacrifice of Isaac",
        scripture: "Genesis 22:1-18",
        teaching: "God tested Abraham by telling him to sacrifice his son Isaac on Mount Moriah. Abraham obeyed in faith, traveling three days with Isaac. When Isaac asked where the lamb was, Abraham replied, 'God himself will provide the lamb.' As Abraham raised the knife, the angel of the Lord stopped him, saying 'Now I know that you fear God.' Abraham looked up and saw a ram caught in a thicket. God reaffirmed His covenant promises. This event foreshadows God providing His own Son as a sacrifice.",
        keyVerse: "Abraham answered, 'God himself will provide the lamb for the burnt offering, my son.' — Genesis 22:8",
        questions: [
          { question: "Where was Abraham told to sacrifice Isaac?", options: ["Mount Sinai","Mount Moriah","Mount Carmel","Mount Nebo"], correct: 1, explanation: "Genesis 22:2 says God told Abraham to go to the region of Moriah and sacrifice Isaac there." },
          { question: "What did God provide as a substitute for Isaac?", options: ["A dove","A lamb","A ram caught in a thicket","Nothing"], correct: 2, explanation: "Genesis 22:13 says Abraham looked up and saw a ram caught by its horns in a thicket." },
          { question: "How many days did Abraham travel to reach the place?", options: ["1 day","2 days","3 days","7 days"], correct: 2, explanation: "Genesis 22:4 says 'On the third day Abraham looked up and saw the place in the distance.'" }
        ]
      },
      {
        id: "patriarchs-4",
        title: "Jacob Wrestles with God",
        scripture: "Genesis 32:22-32",
        teaching: "On the night before meeting his estranged brother Esau, Jacob was left alone by the river Jabbok. A man wrestled with him until daybreak. When the man could not overpower Jacob, he touched Jacob's hip and wrenched it. Jacob refused to let the man go unless he blessed him. The man asked his name, then said, 'Your name will no longer be Jacob, but Israel, because you have struggled with God and with humans and have overcome.' Jacob named the place Peniel, saying 'I saw God face to face, and yet my life was spared.'",
        keyVerse: "Your name will no longer be Jacob, but Israel, because you have struggled with God and with humans and have overcome. — Genesis 32:28",
        questions: [
          { question: "With whom did Jacob wrestle?", options: ["Esau's servant","A wild animal","A divine being","An Egyptian soldier"], correct: 2, explanation: "Genesis 32:28 and Hosea 12:4 indicate Jacob wrestled with God (or an angel of the Lord)." },
          { question: "What new name did Jacob receive?", options: ["Abraham","Isaac","Israel","Judah"], correct: 2, explanation: "Genesis 32:28 says his name would be Israel, meaning 'struggles with God,' because he had overcome." },
          { question: "What injury did Jacob sustain in the wrestling match?", options: ["A broken arm","A dislocated hip","A scar on his face","A torn shoulder"], correct: 1, explanation: "Genesis 32:25 says the man touched Jacob's hip socket so that it was wrenched as they wrestled." }
        ]
      },
      {
        id: "patriarchs-5",
        title: "Joseph and His Brothers",
        scripture: "Genesis 37; 39-45",
        teaching: "Jacob loved his son Joseph more than his other sons and gave him an ornate robe. Joseph's brothers became jealous and sold him to traders heading to Egypt. In Egypt, Joseph served faithfully, was falsely accused and imprisoned, yet God was with him. He interpreted Pharaoh's dreams of seven fat and seven lean years, was made second-in-command, and saved his family during a great famine. When he revealed himself to his brothers he wept and said, 'You intended to harm me, but God intended it for good.'",
        keyVerse: "You intended to harm me, but God intended it for good to accomplish what is now being done, the saving of many lives. — Genesis 50:20",
        questions: [
          { question: "What special gift did Jacob give Joseph?", options: ["A sword","A chariot","A richly ornamented robe","Gold"], correct: 2, explanation: "Genesis 37:3 says Israel loved Joseph more than his other sons and gave him an ornate robe." },
          { question: "What role did Joseph receive in Egypt?", options: ["Chief priest","Military general","Second-in-command to Pharaoh","Head farmer"], correct: 2, explanation: "Genesis 41:40-41 records Pharaoh putting Joseph in charge of the whole land of Egypt." },
          { question: "What was the purpose of Joseph's suffering?", options: ["Punishment for his pride","God intended it for good to save lives","To make him humble","It had no purpose"], correct: 1, explanation: "Joseph told his brothers 'You intended to harm me, but God intended it for good to accomplish the saving of many lives.'" }
        ]
      },
      {
        id: "patriarchs-6",
        title: "Jacob and Esau",
        scripture: "Genesis 25:19-34; 27",
        teaching: "Isaac's wife Rebekah gave birth to twins: Esau, a hunter loved by Isaac, and Jacob, a quiet man loved by Rebekah. God told Rebekah 'the older will serve the younger.' Esau sold his birthright for a bowl of stew. Later, Jacob deceived his aging father Isaac to receive the blessing intended for Esau by wearing goat skins. Though Jacob's methods were deceptive, God's sovereign plan to work through Jacob—whom He later renamed Israel—was not thwarted.",
        keyVerse: "The Lord said to her, 'Two nations are in your womb... one people will be stronger than the other, and the older will serve the younger.' — Genesis 25:23",
        questions: [
          { question: "What did Esau trade to Jacob?", options: ["His wife","His birthright","His land","His weapons"], correct: 1, explanation: "Genesis 25:33 says Esau swore an oath selling his birthright to Jacob in exchange for bread and lentil stew." },
          { question: "What did Jacob use to deceive Isaac?", options: ["A mask","Esau's robe and goat skins","Dark paint","Esau's armor"], correct: 1, explanation: "Genesis 27:16 says Rebekah put goat skins on Jacob's hands and neck to make him feel hairy like Esau." },
          { question: "What did God tell Rebekah about her twins?", options: ["They would both be kings","They would never get along","The older will serve the younger","They would die young"], correct: 2, explanation: "Genesis 25:23 says God told Rebekah 'the older will serve the younger.'" }
        ]
      }
    ]
  },

  // ─── THE EXODUS ───────────────────────────────────────────────────────────
  {
    id: "exodus",
    title: "The Exodus",
    description: "Deliverance from Egypt",
    icon: "🔥",
    color: "from-red-500 to-rose-600",
    lessons: [
      {
        id: "exodus-1",
        title: "Moses and the Burning Bush",
        scripture: "Exodus 3:1-15",
        teaching: "Moses was tending his father-in-law Jethro's flock near Horeb when the angel of the Lord appeared to him in flames of fire from within a bush that did not burn up. God called to Moses from within the bush and told him to remove his sandals, for he was standing on holy ground. God revealed He had seen the misery of His people in Egypt and was sending Moses to deliver them. When Moses asked God's name, God replied, 'I AM WHO I AM.'",
        keyVerse: "God said to Moses, 'I AM WHO I AM. This is what you are to say to the Israelites: I AM has sent me to you.' — Exodus 3:14",
        questions: [
          { question: "Where did Moses see the burning bush?", options: ["Mount Sinai","Mount Horeb","Mount Carmel","Egypt"], correct: 1, explanation: "Exodus 3:1 says Moses came to Horeb, the mountain of God, where he saw the burning bush." },
          { question: "What name did God reveal to Moses?", options: ["El Shaddai","Adonai","I AM WHO I AM","Jehovah Jireh"], correct: 2, explanation: "Exodus 3:14 records God saying 'I AM WHO I AM' (Hebrew: YHWH) as His eternal name." },
          { question: "What was Moses doing when God appeared?", options: ["Praying","Sleeping","Tending sheep","Building an altar"], correct: 2, explanation: "Exodus 3:1 says 'Moses was tending the flock of Jethro his father-in-law, the priest of Midian.'" }
        ]
      },
      {
        id: "exodus-2",
        title: "The Ten Plagues",
        scripture: "Exodus 7-12",
        teaching: "When Pharaoh refused to let God's people go, the Lord sent ten plagues upon Egypt: water turned to blood, frogs, gnats, flies, livestock plague, boils, hail, locusts, darkness, and the death of the firstborn. Each plague demonstrated God's power over the Egyptian gods. The final plague—the death of the firstborn—led to the institution of the Passover, where the Israelites marked their doorposts with lamb's blood so the destroyer would pass over their homes.",
        keyVerse: "The blood will be a sign for you on the houses where you are, and when I see the blood, I will pass over you. — Exodus 12:13",
        questions: [
          { question: "How many plagues did God send on Egypt?", options: ["7","10","12","3"], correct: 1, explanation: "God sent exactly ten plagues on Egypt, each demonstrating His power and sovereignty." },
          { question: "What was the final plague?", options: ["Darkness","Locusts","Death of the firstborn","Hail"], correct: 2, explanation: "The tenth and final plague was the death of every firstborn in Egypt (Exodus 12:29)." },
          { question: "What did the Israelites put on their doorposts?", options: ["Water","Oil","Lamb's blood","Flour"], correct: 2, explanation: "Exodus 12:7 instructs them to take some blood and put it on the doorframes." }
        ]
      },
      {
        id: "exodus-3",
        title: "Crossing the Red Sea",
        scripture: "Exodus 14",
        teaching: "After Pharaoh let the Israelites go, he changed his mind and pursued them with his army. The Israelites found themselves trapped between the sea and the Egyptians. Moses told the terrified people, 'Stand firm and you will see the deliverance the Lord will bring you today.' God told Moses to stretch out his staff over the sea. The waters divided, the Israelites crossed on dry ground, and when the Egyptians followed, the waters returned and covered them.",
        keyVerse: "Moses answered the people, 'Do not be afraid. Stand firm and you will see the deliverance the Lord will bring you today.' — Exodus 14:13",
        questions: [
          { question: "How did the Israelites cross the Red Sea?", options: ["By boat","By swimming","On dry ground through divided waters","They went around it"], correct: 2, explanation: "Exodus 14:22 says 'the Israelites went through the sea on dry ground, with a wall of water on their right and on their left.'" },
          { question: "What happened to the Egyptian army?", options: ["They turned back willingly","They were captured","They were covered by the returning waters","They became Israelites"], correct: 2, explanation: "Exodus 14:28 says 'The water flowed back and covered the chariots and horsemen — the entire army of Pharaoh.'" },
          { question: "What did Moses do to divide the sea?", options: ["Prayed silently","Stretched out his staff","Blew a trumpet","Poured water on it"], correct: 1, explanation: "Exodus 14:16 says God told Moses 'Raise your staff and stretch out your hand over the sea to divide the water.'" }
        ]
      },
      {
        id: "exodus-4",
        title: "The Ten Commandments",
        scripture: "Exodus 20:1-17",
        teaching: "At Mount Sinai, God called Moses up and gave him the Law. The Ten Commandments begin with the declaration that God brought Israel out of slavery. The first four deal with humanity's relationship with God: no other gods, no idols, no misuse of God's name, keep the Sabbath holy. The last six govern human relationships: honor parents, do not murder, do not commit adultery, do not steal, do not give false testimony, do not covet.",
        keyVerse: "You shall have no other gods before me. — Exodus 20:3",
        questions: [
          { question: "Where did God give Moses the Ten Commandments?", options: ["Mount Carmel","Mount Moriah","Mount Sinai","Mount Horeb"], correct: 2, explanation: "Exodus 19-20 describes God meeting Moses at Mount Sinai to give the commandments and the Law." },
          { question: "What is the fourth commandment?", options: ["Do not steal","Honor your father and mother","Remember the Sabbath day to keep it holy","Do not covet"], correct: 2, explanation: "Exodus 20:8 says 'Remember the Sabbath day by keeping it holy.'" },
          { question: "How were the commandments first written?", options: ["On papyrus scrolls","On clay tablets","On stone tablets by the finger of God","Moses wrote them down"], correct: 2, explanation: "Exodus 31:18 says God gave Moses 'two tablets of the covenant law, the tablets of stone inscribed by the finger of God.'" }
        ]
      },
      {
        id: "exodus-5",
        title: "Manna in the Wilderness",
        scripture: "Exodus 16; Numbers 11",
        teaching: "After escaping Egypt, the Israelites grumbled about hunger in the wilderness. God told Moses He would rain down bread from heaven. Each morning a thin flaky substance appeared on the ground — the people called it manna, meaning 'What is it?' God commanded them to gather only what they needed each day, trusting Him for tomorrow. On the sixth day they were to gather double for the Sabbath. This daily provision of manna taught Israel to depend on God completely. Jesus later called Himself the true bread from heaven.",
        keyVerse: "Then the Lord said to Moses, 'I will rain down bread from heaven for you.' — Exodus 16:4",
        questions: [
          { question: "What does the name 'manna' mean?", options: ["Bread from God","What is it?","Sweet like honey","Heaven's gift"], correct: 1, explanation: "Exodus 16:15 says when the Israelites saw it they asked 'What is it?' — the Hebrew 'man hu' gave it its name." },
          { question: "How often did the Israelites gather manna?", options: ["Once a week","Once a month","Every day except the Sabbath","Whenever they were hungry"], correct: 2, explanation: "God commanded them to gather a daily portion every morning. On the sixth day they gathered double so they could rest on the Sabbath." },
          { question: "What did Jesus say about Himself in reference to the manna?", options: ["He was greater than Moses","He was the true bread from heaven","He would provide manna again","He fulfilled the Sabbath law"], correct: 1, explanation: "In John 6:32-35, Jesus said 'I am the bread of life' and that He is the true bread from heaven that gives eternal life." }
        ]
      },
      {
        id: "exodus-6",
        title: "The Golden Calf",
        scripture: "Exodus 32",
        teaching: "While Moses was on Mount Sinai receiving the law, the Israelites grew impatient and asked Aaron to make them gods. Aaron collected their gold earrings and fashioned a golden calf. The people declared, 'These are your gods, Israel, who brought you up out of Egypt!' God told Moses what had happened and was ready to destroy the nation, but Moses interceded in prayer. Moses came down and broke the stone tablets in anger. He burned the calf, ground it to powder, and made the people drink it. About three thousand people died for the sin.",
        keyVerse: "Then Moses interceded with the Lord his God and said, 'Lord, why should your anger burn against your people?' — Exodus 32:11",
        questions: [
          { question: "Why did the Israelites ask for a golden calf?", options: ["They wanted to worship properly","Moses had been gone too long and they grew impatient","They wanted to please Pharaoh","God told them to make one"], correct: 1, explanation: "Exodus 32:1 says 'When the people saw that Moses was so long in coming down from the mountain, they gathered around Aaron.'" },
          { question: "What did Moses do with the golden calf?", options: ["Hid it","Kept it as a memorial","Burned it and ground it to powder","Melted it into tools"], correct: 2, explanation: "Exodus 32:20 says Moses burned the calf, ground it to powder, scattered it on the water, and made the Israelites drink it." },
          { question: "What role did Moses play in this event?", options: ["He led the idol worship","He interceded before God for the people","He punished the people without mercy","He was not present"], correct: 1, explanation: "Moses pleaded with God not to destroy Israel, reminding Him of His covenant promises to Abraham, Isaac, and Jacob (Exodus 32:11-14)." }
        ]
      }
    ]
  },

  // ─── OLD TESTAMENT HISTORY ────────────────────────────────────────────────
  {
    id: "ot-history",
    title: "Old Testament History",
    description: "Joshua, Judges, Ruth & beyond",
    icon: "🏛️",
    color: "from-stone-500 to-slate-600",
    lessons: [
      {
        id: "history-1",
        title: "The Fall of Jericho",
        scripture: "Joshua 6",
        teaching: "After Moses died, Joshua led Israel into the Promised Land. The Lord told Joshua to march his army around the city of Jericho once a day for six days, with seven priests carrying trumpets in front of the ark. On the seventh day they were to march around seven times. When the priests sounded a long blast on the trumpets and the people gave a loud shout, the walls of Jericho collapsed, and every man charged straight in. The prostitute Rahab, who had hidden the Israelite spies and hung a scarlet cord in her window, was saved.",
        keyVerse: "When the trumpets sounded, the army shouted, and at the sound of the trumpet, when the men gave a loud shout, the wall collapsed. — Joshua 6:20",
        questions: [
          { question: "How many days did the Israelites march around Jericho?", options: ["3","5","7","10"], correct: 2, explanation: "Joshua 6:3-4 says they marched around the city once a day for six days, then seven times on the seventh day." },
          { question: "What signal caused the walls to fall?", options: ["A prayer","The ark touching the walls","Trumpets and a loud shout","An earthquake"], correct: 2, explanation: "Joshua 6:20 says when the priests sounded the trumpets and the people shouted, the wall collapsed." },
          { question: "Who was saved from Jericho's destruction?", options: ["The king of Jericho","All who believed","Rahab and her family","No one"], correct: 2, explanation: "Rahab had helped the Israelite spies and hung a scarlet cord as instructed — she and her family were spared (Joshua 6:25)." }
        ]
      },
      {
        id: "history-2",
        title: "Gideon and the Three Hundred",
        scripture: "Judges 6-7",
        teaching: "Israel was oppressed by the Midianites. The angel of the Lord appeared to Gideon and called him a 'mighty warrior,' though Gideon saw himself as the least in his family. God told him to save Israel. God reduced Gideon's army from 32,000 to only 300 men so that Israel could not boast that her own strength saved her. Armed with torches, jars, and trumpets, Gideon's 300 men surrounded the Midianite camp at night. At Gideon's signal they smashed their jars, blew their trumpets, and shouted 'A sword for the Lord and for Gideon!' The Midianites fled in panic.",
        keyVerse: "The Lord said to Gideon, 'You have too many men. I cannot deliver Midian into their hands, or Israel would boast against me.' — Judges 7:2",
        questions: [
          { question: "Why did God reduce Gideon's army?", options: ["To save resources","So Israel would not boast that her own strength saved her","The other men were afraid","Gideon sent them home"], correct: 1, explanation: "Judges 7:2 says God reduced the army so that Israel would not boast 'My own strength has saved me.'" },
          { question: "How large was Gideon's final army?", options: ["100","300","500","1000"], correct: 1, explanation: "God reduced the army to 300 men who lapped water like a dog (Judges 7:7)." },
          { question: "What weapons did Gideon's men carry?", options: ["Swords and shields","Bows and arrows","Torches, clay jars, and trumpets","Spears and chariots"], correct: 2, explanation: "Judges 7:16 says Gideon divided the men into three companies and gave each a trumpet and an empty jar with a torch inside." }
        ]
      },
      {
        id: "history-3",
        title: "The Book of Ruth",
        scripture: "Ruth 1-4",
        teaching: "During the period of the Judges, a famine drove Naomi's family from Bethlehem to Moab. Her husband and both sons died, leaving Naomi with two Moabite daughters-in-law. Naomi urged them to return to their own people. Orpah left, but Ruth clung to Naomi and said, 'Where you go I will go, and where you stay I will stay. Your people will be my people and your God my God.' Ruth gleaned in the fields of Boaz, a relative of Naomi. Boaz showed great kindness and eventually married Ruth. They became ancestors of King David and Jesus.",
        keyVerse: "Where you go I will go, and where you stay I will stay. Your people will be my people and your God my God. — Ruth 1:16",
        questions: [
          { question: "Why did Naomi return to Bethlehem?", options: ["She wanted to sell her land","She heard the Lord had provided food for His people","She was sent away by her sons","Her family summoned her"], correct: 1, explanation: "Ruth 1:6 says Naomi heard that the Lord had come to the aid of his people by providing food for them." },
          { question: "Who was Boaz to Naomi?", options: ["Her brother","A close relative","A neighbor with no relation","The local judge"], correct: 1, explanation: "Ruth 2:20 reveals that Boaz was a close relative of Naomi, a 'guardian-redeemer.'" },
          { question: "Who was Ruth an ancestor of?", options: ["Moses and Aaron","King Saul","King David and Jesus","The prophet Elijah"], correct: 2, explanation: "Ruth 4:17-22 traces the line from Boaz and Ruth through Obed to Jesse to David, ultimately leading to Jesus (Matthew 1:5)." }
        ]
      },
      {
        id: "history-4",
        title: "Esther — For Such a Time as This",
        scripture: "Esther 1-10",
        teaching: "A Jewish girl named Esther was raised by her cousin Mordecai in Persia. She was chosen as queen by King Ahasuerus. When the king's official Haman plotted to kill all the Jews, Mordecai urged Esther to intercede with the king. Esther had not been called before the king for thirty days, and to approach uninvited risked death. Mordecai told her, 'Who knows whether you have not come to the kingdom for such a time as this?' Esther fasted for three days, then bravely approached the king. The king extended his scepter, the plot was exposed, Haman was hanged, and the Jewish people were saved.",
        keyVerse: "Who knows whether you have not come to the kingdom for such a time as this? — Esther 4:14",
        questions: [
          { question: "What was the name of the official who plotted to kill the Jews?", options: ["Mordecai","Cyrus","Haman","Artaxerxes"], correct: 2, explanation: "Esther 3:6 says Haman sought to destroy all the Jews throughout the whole kingdom because Mordecai would not kneel to him." },
          { question: "What risk did Esther face by approaching the king uninvited?", options: ["Losing her title","Being sent away","Death","Exile"], correct: 2, explanation: "Esther 4:11 explains that Persian law demanded death for anyone who approached the king unsummoned unless the king extended his golden scepter." },
          { question: "What did Esther do for three days before approaching the king?", options: ["Prayed loudly in the courtyard","Fasted along with the Jewish people","Sent letters to all the provinces","Gathered an army"], correct: 1, explanation: "Esther 4:16 says Esther called all the Jews in Susa to fast for her for three days before she would go to the king." }
        ]
      },
      {
        id: "history-5",
        title: "Job — Suffering and Faith",
        scripture: "Job 1-2; 38-42",
        teaching: "Job was a blameless and upright man who feared God. Satan challenged God, saying Job only worshiped Him because of his blessings. God permitted Satan to test Job. Job lost his children, his wealth, and his health. His friends insisted his suffering must be punishment for hidden sin. Job wrestled honestly with God. Then God spoke from a whirlwind, reminding Job of His sovereignty over all creation. Job repented of demanding an explanation and prayed for his friends. God restored Job's fortunes double. The book teaches that suffering is not always punishment, and that God can be trusted even in darkness.",
        keyVerse: "I know that my redeemer lives, and that in the end he will stand on the earth. — Job 19:25",
        questions: [
          { question: "Why did God allow Satan to test Job?", options: ["Job had sinned secretly","God wanted to prove that Job's faith was genuine, not based on blessings","Job was the strongest man","God needed to punish Israel"], correct: 1, explanation: "Job 1:8-12 shows God pointing out Job's righteousness while Satan challenged that Job only feared God because of his blessings." },
          { question: "What was wrong with the advice of Job's three friends?", options: ["They were too sympathetic","They insisted all suffering is punishment for specific sin","They told Job to curse God","They urged Job to fight back"], correct: 1, explanation: "Job 42:7 says God was angry with Eliphaz and his friends because they had 'not spoken the truth about me, as my servant Job has.'" },
          { question: "How did Job's story end?", options: ["Job died in his suffering","God answered Job but did not restore him","God restored Job's fortunes double","Job left his faith behind"], correct: 2, explanation: "Job 42:10-17 says the Lord restored Job's fortunes and gave him twice as much as he had before." }
        ]
      },
      {
        id: "history-6",
        title: "Nehemiah Rebuilds the Wall",
        scripture: "Nehemiah 1-6",
        teaching: "Nehemiah was the cupbearer to the Persian king Artaxerxes. When he heard Jerusalem's walls were broken down and its gates burned, he wept, fasted, and prayed. He confessed the sins of his people and asked God to give him favor. The king noticed his sadness and asked what he wanted. Nehemiah prayed quickly, then asked for permission to rebuild Jerusalem. The king agreed. Despite fierce opposition and mockery from enemies like Sanballat and Tobiah, Nehemiah organized the people and the wall was rebuilt in 52 days. Nehemiah prayed constantly throughout, showing that prayer and action work together.",
        keyVerse: "The God of heaven will give us success. We his servants will start rebuilding. — Nehemiah 2:20",
        questions: [
          { question: "What was Nehemiah's job in Persia?", options: ["Soldier","Scribe","Cupbearer to the king","Head builder"], correct: 2, explanation: "Nehemiah 1:11 says Nehemiah was the cupbearer to King Artaxerxes — a position of great trust and access." },
          { question: "How long did it take to rebuild the wall of Jerusalem?", options: ["7 days","52 days","1 year","5 years"], correct: 1, explanation: "Nehemiah 6:15 says 'So the wall was completed on the twenty-fifth of Elul, in fifty-two days.'" },
          { question: "What did Nehemiah do when he heard about Jerusalem's broken walls?", options: ["Immediately left Persia","Organized an army","Wept, fasted, and prayed","Wrote to all the provinces"], correct: 2, explanation: "Nehemiah 1:4 says 'When I heard these things, I sat down and wept. For some days I mourned and fasted and prayed before the God of heaven.'" }
        ]
      }
    ]
  },

  // ─── KINGS & PROPHETS ─────────────────────────────────────────────────────
  {
    id: "kings-prophets",
    title: "Kings & Prophets",
    description: "Israel's rulers and God's messengers",
    icon: "👑",
    color: "from-indigo-500 to-blue-600",
    lessons: [
      {
        id: "kings-1",
        title: "David and Goliath",
        scripture: "1 Samuel 17",
        teaching: "The Philistines and Israelites faced each other for battle, and the Philistine champion Goliath challenged Israel to send one man to fight him. The entire army was afraid. Young David heard Goliath's defiance and said, 'Who is this uncircumcised Philistine that he should defy the armies of the living God?' Armed with only a sling and five smooth stones, trusting fully in God, David ran toward Goliath, struck him on the forehead with a stone, and the giant fell.",
        keyVerse: "David said to the Philistine, 'You come against me with sword and spear and javelin, but I come against you in the name of the Lord Almighty.' — 1 Samuel 17:45",
        questions: [
          { question: "How tall was Goliath according to Scripture?", options: ["Six feet","Seven feet","Over nine feet","Twelve feet"], correct: 2, explanation: "1 Samuel 17:4 says Goliath's height was 'six cubits and a span,' approximately nine feet nine inches." },
          { question: "What weapons did David use to defeat Goliath?", options: ["A sword and shield","A bow and arrow","A sling and a stone","A spear"], correct: 2, explanation: "David took his sling and five smooth stones from a stream and struck Goliath on the forehead (1 Samuel 17:49)." },
          { question: "What was David's source of confidence against Goliath?", options: ["His military training","His size and strength","Trust in God and past victories with lions and bears","Goliath was weak"], correct: 2, explanation: "David told Saul that God had delivered him from lions and bears and would deliver him from Goliath too (1 Samuel 17:37)." }
        ]
      },
      {
        id: "kings-2",
        title: "Solomon's Wisdom",
        scripture: "1 Kings 3; 4:29-34",
        teaching: "After David died, his son Solomon became king. God appeared to Solomon in a dream and said, 'Ask for whatever you want me to give you.' Rather than asking for wealth, long life, or victory over enemies, Solomon asked for a discerning heart to govern the people and distinguish right from wrong. God was pleased and gave him not only wisdom but also wealth and honor. Solomon's wisdom surpassed all others; kings from all nations came to hear him. He wrote Proverbs, Ecclesiastes, and the Song of Songs.",
        keyVerse: "So give your servant a discerning heart to govern your people and to distinguish between right and wrong. — 1 Kings 3:9",
        questions: [
          { question: "What did Solomon ask God for?", options: ["Wealth and long life","Victory over enemies","A discerning heart and wisdom","A great army"], correct: 2, explanation: "Solomon asked for a discerning heart to govern and distinguish right from wrong, which pleased God greatly (1 Kings 3:9)." },
          { question: "Why was God pleased with Solomon's request?", options: ["It was the most expensive request","Solomon did not ask for selfish things","It made God feel important","Solomon was already wise"], correct: 1, explanation: "1 Kings 3:11-12 says God was pleased that Solomon had not asked for long life, riches, or the death of his enemies." },
          { question: "Which books of the Bible are traditionally attributed to Solomon?", options: ["Psalms and Prophets","Proverbs, Ecclesiastes, and Song of Songs","Kings and Chronicles","Ruth and Esther"], correct: 1, explanation: "Tradition attributes Proverbs, Ecclesiastes, and Song of Songs to Solomon, who spoke 3,000 proverbs (1 Kings 4:32)." }
        ]
      },
      {
        id: "kings-3",
        title: "Elijah and the Prophets of Baal",
        scripture: "1 Kings 18:16-46",
        teaching: "Israel under King Ahab had turned to worshiping Baal. The prophet Elijah challenged 450 prophets of Baal to a contest on Mount Carmel: each side would prepare a bull on an altar, and the god who answered by fire would be the true God. The prophets of Baal cried out all day — no answer. Then Elijah repaired the altar, drenched it with water three times, and prayed a simple prayer. The fire of the Lord fell and consumed the offering, the wood, the stones, and even the water. All the people fell and cried, 'The Lord — he is God!'",
        keyVerse: "Answer me, Lord, answer me, so these people will know that you, Lord, are God. — 1 Kings 18:37",
        questions: [
          { question: "How many prophets of Baal did Elijah challenge?", options: ["100","200","450","1000"], correct: 2, explanation: "1 Kings 18:22 says Elijah was the only remaining prophet of the Lord, while Baal had 450 prophets." },
          { question: "What did Elijah do to make the challenge harder?", options: ["Fasted for three days","Drenched the altar with water three times","Built a higher altar","Prayed for an hour"], correct: 1, explanation: "1 Kings 18:33-35 records Elijah having four large jars of water poured on the offering three times." },
          { question: "What did the people shout when the fire fell?", options: ["Elijah is God!","Baal is defeated!","The Lord — he is God!","We believe in fire!"], correct: 2, explanation: "1 Kings 18:39 says 'When all the people saw this, they fell prostrate and cried: The Lord — he is God! The Lord — he is God!'" }
        ]
      },
      {
        id: "kings-4",
        title: "Isaiah's Vision",
        scripture: "Isaiah 6:1-8; 53",
        teaching: "In the year that King Uzziah died, Isaiah saw a vision of the Lord seated on a high and exalted throne. Seraphim called, 'Holy, holy, holy is the Lord Almighty; the whole earth is full of his glory.' Isaiah cried out, 'Woe to me! I am ruined! For I am a man of unclean lips.' A seraph touched his lips with a live coal and declared him cleansed. Then God asked, 'Whom shall I send?' Isaiah responded, 'Here am I. Send me!' Isaiah also prophesied of a Suffering Servant who would bear our griefs — a passage Christians see fulfilled in Jesus.",
        keyVerse: "Here am I. Send me! — Isaiah 6:8",
        questions: [
          { question: "What did the seraphim cry out in Isaiah's vision?", options: ["Peace, peace, peace","Holy, holy, holy is the Lord Almighty","Fire, fire, fire","Come, come, come"], correct: 1, explanation: "Isaiah 6:3 records the seraphim calling 'Holy, holy, holy is the Lord Almighty; the whole earth is full of his glory.'" },
          { question: "How was Isaiah cleansed in his vision?", options: ["By water from heaven","A seraph touched his lips with a live coal","By an angel's touch","By a bright light"], correct: 1, explanation: "Isaiah 6:6-7 says a seraph took a live coal from the altar and touched Isaiah's mouth, declaring his guilt was taken away." },
          { question: "Isaiah 53 describes the Suffering Servant as doing what?", options: ["Leading an army","Becoming a king","Bearing others' griefs and being wounded for their transgressions","Performing miracles"], correct: 2, explanation: "Isaiah 53:4-5 says 'Surely he took up our pain and bore our suffering... he was pierced for our transgressions.' Christians see this fulfilled in Jesus." }
        ]
      },
      {
        id: "kings-5",
        title: "Daniel in the Lion's Den",
        scripture: "Daniel 6",
        teaching: "Daniel served faithfully in Babylon under King Darius. Out of jealousy, administrators tricked the king into a law forbidding prayer to anyone but the king for thirty days. Daniel continued praying three times a day with his windows open. He was thrown into the lions' den. The king fasted all night and rushed to the den in the morning, calling out to Daniel. Daniel answered that God had sent an angel to shut the lions' mouths. Darius then issued a decree honoring the God of Daniel.",
        keyVerse: "My God sent his angel, and he shut the mouths of the lions. They have not hurt me, because I was found innocent in his sight. — Daniel 6:22",
        questions: [
          { question: "Why was Daniel thrown into the lions' den?", options: ["He stole from the king","He refused to stop praying to God","He led a rebellion","He insulted King Darius"], correct: 1, explanation: "Daniel 6:10 says that when Daniel learned the decree had been signed, he went home and prayed three times a day as he had always done." },
          { question: "What did the king do the night Daniel was in the den?", options: ["Celebrated with feasts","Slept peacefully","Spent the night fasting and could not sleep","Prayed to Baal"], correct: 2, explanation: "Daniel 6:18 says 'the king returned to his palace and spent the night without eating... And he could not sleep.'" },
          { question: "What did God do to protect Daniel?", options: ["Removed Daniel from the den","Sent an earthquake","Sent an angel to shut the lions' mouths","Made Daniel invisible"], correct: 2, explanation: "Daniel 6:22 says 'My God sent his angel, and he shut the mouths of the lions. They have not hurt me.'" }
        ]
      },
      {
        id: "kings-6",
        title: "Saul: Israel's First King",
        scripture: "1 Samuel 8-15",
        teaching: "Israel demanded a king to be like the other nations. God warned through Samuel that a king would take their sons for war, their daughters for service, and a portion of their crops — but the people insisted. God gave them Saul, a tall and handsome man from the tribe of Benjamin. Saul started well but his pride and disobedience led to his downfall. When Saul offered an unauthorized sacrifice and spared enemy King Agag against God's direct command, Samuel rebuked him: 'To obey is better than sacrifice.' God rejected Saul and chose David instead.",
        keyVerse: "To obey is better than sacrifice, and to heed is better than the fat of rams. — 1 Samuel 15:22",
        questions: [
          { question: "Why did Israel demand a king?", options: ["Samuel's sons were corrupt judges","They wanted to be like other nations","God commanded it","Their enemies had better armies"], correct: 1, explanation: "1 Samuel 8:5 says the elders told Samuel 'appoint a king to lead us, such as all the other nations have.'" },
          { question: "What did Saul do that caused God to reject him?", options: ["He built an idol","He fled from battle","He disobeyed by offering an unauthorized sacrifice and sparing King Agag","He married a foreign woman"], correct: 2, explanation: "1 Samuel 13 and 15 record Saul's two major acts of disobedience that led to God's rejection of him as king." },
          { question: "What key truth did Samuel teach Saul about obedience?", options: ["Sacrifice pleases God most","A king can set his own rules","To obey is better than sacrifice","Prayer replaces obedience"], correct: 2, explanation: "1 Samuel 15:22 says 'To obey is better than sacrifice, and to heed is better than the fat of rams.'" }
        ]
      },
      {
        id: "kings-7",
        title: "Jonah and the Great Fish",
        scripture: "Jonah 1-4",
        teaching: "God commanded Jonah to go to Nineveh, the capital of Assyria, and preach against its wickedness. Jonah fled in the opposite direction by ship. God sent a great storm and Jonah was thrown overboard. A great fish swallowed Jonah, and he remained inside for three days and nights, praying. The fish vomited Jonah onto dry land. Jonah obeyed this time and preached in Nineveh. Remarkably, the entire city — from the king to the least — repented. Jonah was angry that God showed mercy to Israel's enemy. God rebuked Jonah for caring more about a plant than 120,000 people.",
        keyVerse: "Should I not have concern for the great city of Nineveh, in which there are more than a hundred and twenty thousand people? — Jonah 4:11",
        questions: [
          { question: "Why did Jonah flee instead of going to Nineveh?", options: ["He was afraid of the journey","He knew God might show mercy to Israel's enemies and he did not want that","He did not believe God could save Nineveh","He was sick"], correct: 1, explanation: "Jonah 4:2 reveals that Jonah knew God was compassionate and might relent from sending disaster — and he did not want Nineveh to be spared." },
          { question: "How long was Jonah inside the great fish?", options: ["One day","Two days","Three days and nights","Seven days"], correct: 2, explanation: "Jonah 1:17 says 'Now the Lord provided a huge fish to swallow Jonah, and Jonah was in the belly of the fish three days and three nights.'" },
          { question: "What was Nineveh's response to Jonah's preaching?", options: ["They attacked Jonah","They ignored him","The entire city repented, from king to commoner","Half the city believed"], correct: 2, explanation: "Jonah 3:5-10 describes a remarkable city-wide repentance, with the king declaring a fast and ordering everyone to call urgently on God." }
        ]
      }
    ]
  },

  // ─── LIFE OF JESUS ────────────────────────────────────────────────────────
  {
    id: "life-of-jesus",
    title: "Life of Jesus",
    description: "From birth to ascension",
    icon: "⭐",
    color: "from-pink-500 to-rose-500",
    lessons: [
      {
        id: "lifej-1",
        title: "The Birth of Jesus",
        scripture: "Luke 1:26-38; 2:1-20",
        teaching: "The angel Gabriel appeared to Mary, a young virgin betrothed to Joseph, and told her she would conceive and bear the Son of God through the Holy Spirit. Mary responded, 'I am the Lord's servant. May your word to me be fulfilled.' Joseph, troubled by Mary's pregnancy, was reassured by an angel in a dream. Caesar Augustus issued a census, so Joseph and Mary traveled to Bethlehem. There Mary gave birth to Jesus in a manger because there was no room in the inn. Angels appeared to shepherds, who hurried to find the baby. This fulfilled the prophecy of Micah 5:2 that the Messiah would be born in Bethlehem.",
        keyVerse: "She will give birth to a son, and you are to give him the name Jesus, because he will save his people from their sins. — Matthew 1:21",
        questions: [
          { question: "Why was Jesus born in Bethlehem?", options: ["It was Mary's hometown","A Roman census required Joseph to travel there","An angel directed them there","Joseph worked there"], correct: 1, explanation: "Luke 2:1-4 says a census required everyone to travel to their own town. Joseph went to Bethlehem, the town of David, because he was of David's line." },
          { question: "Who were the first people to be told about Jesus' birth by angels?", options: ["The wise men","The priests in Jerusalem","Shepherds in the fields","King Herod"], correct: 2, explanation: "Luke 2:8-11 says an angel appeared to shepherds watching their flocks at night and announced the birth of the Savior." },
          { question: "What was Mary's response to the angel Gabriel's announcement?", options: ["She refused","She was excited and immediately told everyone","I am the Lord's servant; may your word be fulfilled","She asked for proof"], correct: 2, explanation: "Luke 1:38 records Mary's beautiful submission: 'I am the Lord's servant. May your word to me be fulfilled.'" }
        ]
      },
      {
        id: "lifej-2",
        title: "The Baptism and Temptation of Jesus",
        scripture: "Matthew 3:13-4:11",
        teaching: "John the Baptist was baptizing people in the Jordan River when Jesus came to be baptized. John tried to deter Him, saying he needed to be baptized by Jesus. Jesus insisted, saying it was proper to fulfill all righteousness. When Jesus came up out of the water, the heavens opened, the Spirit of God descended like a dove, and a voice said, 'This is my Son, whom I love; with him I am well pleased.' Then the Spirit led Jesus into the wilderness, where He fasted forty days and was tempted by the devil three times. Jesus defeated each temptation by quoting Scripture.",
        keyVerse: "This is my Son, whom I love; with him I am well pleased. — Matthew 3:17",
        questions: [
          { question: "What happened immediately after Jesus was baptized?", options: ["He began preaching","The Spirit descended like a dove and a voice spoke from heaven","He healed the sick","He walked on water"], correct: 1, explanation: "Matthew 3:16-17 says the heavens opened, the Spirit descended like a dove, and God's voice declared 'This is my Son, whom I love.'" },
          { question: "How long did Jesus fast in the wilderness?", options: ["7 days","21 days","40 days","3 days"], correct: 2, explanation: "Matthew 4:2 says 'After fasting forty days and forty nights, he was hungry.'" },
          { question: "How did Jesus defeat each of Satan's temptations?", options: ["By performing miracles","By calling on angels","By quoting Scripture","By ignoring Satan"], correct: 2, explanation: "Each time Satan tempted Jesus, He responded with 'It is written' and quoted from Deuteronomy, defeating the temptations through the Word of God." }
        ]
      },
      {
        id: "lifej-3",
        title: "The Transfiguration",
        scripture: "Matthew 17:1-13",
        teaching: "Six days after Peter confessed that Jesus was the Messiah, Jesus took Peter, James, and John up a high mountain. There He was transfigured before them — His face shone like the sun and His clothes became as white as the light. Moses and Elijah appeared and talked with Him. Peter suggested building three shelters. Suddenly a bright cloud covered them and a voice said, 'This is my Son, whom I love; with him I am well pleased. Listen to him!' The disciples fell face down, overwhelmed with fear. When they looked up, they saw only Jesus. As they descended, Jesus told them to tell no one until He had risen from the dead.",
        keyVerse: "This is my Son, whom I love; with him I am well pleased. Listen to him! — Matthew 17:5",
        questions: [
          { question: "Who appeared with Jesus during the Transfiguration?", options: ["Abraham and Elijah","Moses and Elijah","David and Isaiah","John the Baptist and Moses"], correct: 1, explanation: "Matthew 17:3 says Moses and Elijah appeared and were talking with Jesus." },
          { question: "What did Jesus' appearance look like during the Transfiguration?", options: ["He glowed green","His face shone like the sun and His clothes were white as light","He became invisible","He appeared as an angel"], correct: 1, explanation: "Matthew 17:2 says 'His face shone like the sun, and his clothes became as white as the light.'" },
          { question: "What did God command the disciples to do at the Transfiguration?", options: ["Build shelters","Fall prostrate","Go tell others","Listen to Jesus"], correct: 3, explanation: "Matthew 17:5 records God saying 'This is my Son, whom I love; with him I am well pleased. Listen to him!'" }
        ]
      },
      {
        id: "lifej-4",
        title: "The Triumphal Entry",
        scripture: "Matthew 21:1-17",
        teaching: "As Jesus approached Jerusalem, He sent disciples to get a donkey and her colt. He rode into Jerusalem on the colt, fulfilling Zechariah 9:9: 'See, your king comes to you, gentle and riding on a donkey.' Huge crowds spread their cloaks and palm branches on the road, shouting 'Hosanna to the Son of David! Blessed is he who comes in the name of the Lord!' Jerusalem was stirred. Jesus entered the temple and drove out those buying and selling, overturning the money changers' tables, declaring, 'My house will be called a house of prayer, but you are making it a den of robbers.' The blind and lame came to Him in the temple and He healed them.",
        keyVerse: "Blessed is he who comes in the name of the Lord! Hosanna in the highest heaven! — Matthew 21:9",
        questions: [
          { question: "What animal did Jesus ride into Jerusalem?", options: ["A horse","A camel","A donkey's colt","A white mule"], correct: 2, explanation: "Matthew 21:5 fulfills Zechariah 9:9: 'See, your king comes to you, gentle and riding on a donkey, and on a colt, the foal of a donkey.'" },
          { question: "What did the crowds shout as Jesus entered Jerusalem?", options: ["Hosanna to the Son of David","Long live the king","Praise to the prophet","God save us from Rome"], correct: 0, explanation: "Matthew 21:9 records the crowds shouting 'Hosanna to the Son of David! Blessed is he who comes in the name of the Lord!'" },
          { question: "What did Jesus do when He entered the temple?", options: ["Preached a long sermon","Drove out those buying and selling","Sat with the Pharisees","Offered a sacrifice"], correct: 1, explanation: "Matthew 21:12-13 says Jesus drove out those buying and selling, overturned money changers' tables, calling the temple 'a house of prayer.'" }
        ]
      },
      {
        id: "lifej-5",
        title: "The Garden of Gethsemane",
        scripture: "Matthew 26:36-56",
        teaching: "After the Last Supper, Jesus went to the Garden of Gethsemane with His disciples. He took Peter, James, and John aside and said, 'My soul is overwhelmed with sorrow to the point of death.' He fell with His face to the ground and prayed, 'My Father, if it is possible, may this cup be taken from me. Yet not as I will, but as you will.' He found His disciples sleeping three times. When Judas arrived with soldiers, Jesus said, 'Rise! Let us go! Here comes my betrayer!' Judas greeted Jesus with a kiss and Jesus was arrested. Jesus rebuked those who drew swords, saying all this happened to fulfill Scripture.",
        keyVerse: "My Father, if it is possible, may this cup be taken from me. Yet not as I will, but as you will. — Matthew 26:39",
        questions: [
          { question: "What did Jesus pray in the garden?", options: ["For the disciples to be protected","That the cup be taken from Him, yet surrendering to God's will","For victory over His enemies","That Judas would repent"], correct: 1, explanation: "Matthew 26:39 records Jesus' prayer: 'My Father, if it is possible, may this cup be taken from me. Yet not as I will, but as you will.'" },
          { question: "What were Peter, James, and John doing instead of watching?", options: ["Praying together","Fleeing from soldiers","Sleeping","Arguing"], correct: 2, explanation: "Matthew 26:40 says Jesus returned and found them sleeping, saying 'Couldn't you keep watch with me for one hour?'" },
          { question: "How did Judas identify Jesus to the soldiers?", options: ["He pointed at Him","He called out His name","He greeted Him with a kiss","He handed over a written description"], correct: 2, explanation: "Matthew 26:48-49 says Judas had arranged a signal: 'The one I kiss is the man; arrest him.' He went to Jesus and kissed him." }
        ]
      }
    ]
  },

  // ─── TEACHINGS OF JESUS ───────────────────────────────────────────────────
  {
    id: "teachings-jesus",
    title: "Teachings of Jesus",
    description: "The words of Christ",
    icon: "✝️",
    color: "from-violet-500 to-purple-600",
    lessons: [
      {
        id: "jesus-1",
        title: "The Sermon on the Mount",
        scripture: "Matthew 5:1-12",
        teaching: "Jesus went up on a mountainside and began teaching His disciples the Beatitudes — blessings for the poor in spirit, those who mourn, the meek, those who hunger for righteousness, the merciful, the pure in heart, the peacemakers, and those persecuted for righteousness' sake. These teachings turned worldly values upside down, showing that God's kingdom operates by different principles. True blessedness comes not from worldly success but from a humble, righteous heart before God.",
        keyVerse: "Blessed are the poor in spirit, for theirs is the kingdom of heaven. — Matthew 5:3",
        questions: [
          { question: "What are the blessings in Matthew 5 commonly called?", options: ["The Commandments","The Beatitudes","The Parables","The Proverbs"], correct: 1, explanation: "The blessings Jesus pronounced in Matthew 5:3-12 are known as the Beatitudes, from the Latin 'beatus' meaning blessed." },
          { question: "Who did Jesus say would inherit the earth?", options: ["The rich","The powerful","The meek","The wise"], correct: 2, explanation: "Matthew 5:5 says 'Blessed are the meek, for they will inherit the earth.'" },
          { question: "Where did Jesus deliver this sermon?", options: ["The temple","A mountainside","By the sea","In a synagogue"], correct: 1, explanation: "Matthew 5:1 says 'Now when Jesus saw the crowds, he went up on a mountainside and sat down.'" }
        ]
      },
      {
        id: "jesus-2",
        title: "The Parable of the Prodigal Son",
        scripture: "Luke 15:11-32",
        teaching: "Jesus told of a man with two sons. The younger asked for his inheritance early, went to a far country, and squandered it in wild living. When a famine came, he found himself feeding pigs and longing to eat their food. He came to his senses and returned home, prepared to be a servant. But his father saw him from far off, ran to him, embraced him, and threw a great celebration. The older brother was angry, but the father said, 'This brother of yours was dead and is alive again; he was lost and is found.'",
        keyVerse: "But while he was still a long way off, his father saw him and was filled with compassion for him; he ran to his son, threw his arms around him and kissed him. — Luke 15:20",
        questions: [
          { question: "What did the younger son do with his inheritance?", options: ["Invested it wisely","Gave it to the poor","Squandered it in wild living","Built a house"], correct: 2, explanation: "Luke 15:13 says he 'squandered his wealth in wild living.'" },
          { question: "How did the father respond when the son returned?", options: ["Turned him away","Made him a servant","Ran to him and embraced him","Ignored him"], correct: 2, explanation: "Luke 15:20 says the father 'was filled with compassion for him; he ran to his son, threw his arms around him and kissed him.'" },
          { question: "What is the main lesson of this parable?", options: ["Save your money","God's boundless love and forgiveness","Obey your parents","Work hard"], correct: 1, explanation: "The parable illustrates God's extraordinary love and willingness to forgive and restore those who repent and return to Him." }
        ]
      },
      {
        id: "jesus-3",
        title: "The Good Samaritan",
        scripture: "Luke 10:25-37",
        teaching: "A lawyer asked Jesus, 'Who is my neighbor?' Jesus told of a man traveling from Jerusalem to Jericho who was robbed, beaten, and left half dead. A priest and a Levite each passed by on the other side. But a Samaritan — despised by Jews — stopped, bandaged his wounds, brought him to an inn, and paid for his care. Jesus asked, 'Which of these three was a neighbor?' The lawyer answered, 'The one who had mercy.' Jesus said, 'Go and do likewise.'",
        keyVerse: "But a Samaritan, as he traveled, came where the man was; and when he saw him, he took pity on him. — Luke 10:33",
        questions: [
          { question: "Who passed by the injured man without helping?", options: ["A Samaritan and a Roman","A priest and a Levite","Two disciples","A merchant and a soldier"], correct: 1, explanation: "Luke 10:31-32 tells us a priest and a Levite each saw the man but passed by on the other side." },
          { question: "Who stopped to help the injured man?", options: ["A priest","A Levite","A Samaritan","A Roman soldier"], correct: 2, explanation: "Luke 10:33 says 'But a Samaritan, as he traveled, came where the man was; and when he saw him, he took pity on him.'" },
          { question: "What question prompted Jesus to tell this parable?", options: ["How to pray","Who is my neighbor?","How to be saved","When will the kingdom come?"], correct: 1, explanation: "Luke 10:29 says the lawyer asked 'And who is my neighbor?' to justify himself." }
        ]
      },
      {
        id: "jesus-4",
        title: "The Lord's Prayer",
        scripture: "Matthew 6:5-15",
        teaching: "In the Sermon on the Mount, Jesus taught His disciples how to pray. He warned against praying to be seen by others. Instead, go into your room, close the door, and pray to your Father in private. He gave them a model prayer: Our Father in heaven, hallowed be your name, your kingdom come, your will be done on earth as in heaven. Give us daily bread. Forgive our debts as we forgive others. Lead us not into temptation, but deliver us from evil. Jesus emphasized that we must forgive others for God to forgive us.",
        keyVerse: "Our Father in heaven, hallowed be your name, your kingdom come, your will be done, on earth as it is in heaven. — Matthew 6:9-10",
        questions: [
          { question: "What did Jesus warn against when teaching about prayer?", options: ["Praying too long","Praying loudly","Praying to be seen by others","Praying at night"], correct: 2, explanation: "Matthew 6:5 warns against praying 'to be seen by others' like the hypocrites." },
          { question: "What does the Lord's Prayer ask for regarding forgiveness?", options: ["That we would never sin","Forgive our debts as we forgive our debtors","That God would punish our enemies","That we would forget past wrongs"], correct: 1, explanation: "Matthew 6:12 says 'And forgive us our debts, as we also have forgiven our debtors.'" },
          { question: "According to Jesus, what happens if we do not forgive others?", options: ["Nothing changes","We lose our blessings","Our Father will not forgive our sins","We must fast for 40 days"], correct: 2, explanation: "Matthew 6:15 says 'But if you do not forgive others their sins, your Father will not forgive your sins.'" }
        ]
      },
      {
        id: "jesus-5",
        title: "The Last Supper",
        scripture: "Matthew 26:17-30",
        teaching: "On the night Jesus was betrayed, He gathered His twelve disciples for the Passover meal. During the meal, He announced that one of them would betray Him. Then He took bread, gave thanks, broke it and said, 'Take and eat; this is my body.' He took the cup of wine and said, 'This is my blood of the covenant, which is poured out for many for the forgiveness of sins.' This meal, called the Lord's Supper or Communion, is observed by Christians worldwide as a memorial of Christ's sacrifice.",
        keyVerse: "This is my blood of the covenant, which is poured out for many for the forgiveness of sins. — Matthew 26:28",
        questions: [
          { question: "What feast was being celebrated at the Last Supper?", options: ["The Feast of Tabernacles","The Passover","Pentecost","The Feast of First Fruits"], correct: 1, explanation: "Matthew 26:17-18 says the disciples asked Jesus where to prepare the Passover meal." },
          { question: "What did Jesus say the bread represented?", options: ["His teachings","His body","Daily bread from God","The Law of Moses"], correct: 1, explanation: "Matthew 26:26 records Jesus saying 'Take and eat; this is my body.'" },
          { question: "What did Jesus announce during the meal?", options: ["The Spirit would come","One of them would betray Him","They would all abandon Him","The temple would fall"], correct: 1, explanation: "Matthew 26:21 says Jesus announced 'Truly I tell you, one of you will betray me.'" }
        ]
      },
      {
        id: "jesus-6",
        title: "The Feeding of the Five Thousand",
        scripture: "John 6:1-15",
        teaching: "A great crowd followed Jesus because of His healing miracles. Jesus looked up and said to Philip, 'Where shall we buy bread for these people to eat?' He asked this to test Philip, for He already knew what He would do. Andrew reported that a boy had five small barley loaves and two small fish, but said, 'How far will they go among so many?' Jesus had the people sit down — about five thousand men. He gave thanks, distributed the bread and fish, and everyone ate as much as they wanted. Twelve basketfuls of broken pieces were left over. The miracle revealed Jesus as the true bread from heaven.",
        keyVerse: "Jesus then took the loaves, gave thanks, and distributed to those who were seated as much as they wanted. — John 6:11",
        questions: [
          { question: "What food did the boy have?", options: ["Ten loaves and five fish","Five loaves and two fish","Two loaves and ten fish","A basket of figs"], correct: 1, explanation: "John 6:9 says Andrew reported 'Here is a boy with five small barley loaves and two small fish.'" },
          { question: "How many people were fed?", options: ["500","1000","5000","10000"], correct: 2, explanation: "John 6:10 says there were about five thousand men, plus women and children." },
          { question: "What happened to the leftovers?", options: ["Nothing was left","One basket was filled","Twelve baskets were filled","The crowd took everything"], correct: 2, explanation: "John 6:13 says they filled twelve baskets with the pieces of the five barley loaves left over after everyone had eaten." }
        ]
      },
      {
        id: "jesus-7",
        title: "I Am the Way",
        scripture: "John 14:1-14",
        teaching: "On the night of the Last Supper, Jesus comforted His disciples who were troubled by His announcement of departure. He told them He was going to prepare a place for them in His Father's house, and that He would come back to take them to be with Him. Thomas asked, 'Lord, we don't know where you are going, so how can we know the way?' Jesus replied with one of the great I AM statements: 'I am the way and the truth and the life. No one comes to the Father except through me.' He promised that He and the Father were one, and that He would do whatever they asked in His name.",
        keyVerse: "I am the way and the truth and the life. No one comes to the Father except through me. — John 14:6",
        questions: [
          { question: "What did Jesus say He was going to prepare?", options: ["A new temple","A place for them in His Father's house","A new kingdom on earth","A better law"], correct: 1, explanation: "John 14:2-3 says 'My Father's house has many rooms... I am going there to prepare a place for you.'" },
          { question: "What are the three things Jesus calls Himself in John 14:6?", options: ["Light, life, love","Way, truth, life","Door, shepherd, vine","King, prophet, priest"], correct: 1, explanation: "Jesus declared 'I am the way and the truth and the life' — three exclusive claims about Himself." },
          { question: "What did Jesus say His disciples would be able to do in His name?", options: ["Command armies","Ask for anything and He would do it","Forgive all sins","Raise the dead on their own"], correct: 1, explanation: "John 14:13-14 says 'I will do whatever you ask in my name... You may ask me for anything in my name, and I will do it.'" }
        ]
      }
    ]
  },

  // ─── MIRACLES OF JESUS ────────────────────────────────────────────────────
  {
    id: "miracles-jesus",
    title: "Miracles of Jesus",
    description: "Signs and wonders of Christ",
    icon: "✨",
    color: "from-cyan-500 to-sky-600",
    lessons: [
      {
        id: "miracle-1",
        title: "Water Into Wine",
        scripture: "John 2:1-12",
        teaching: "Jesus and His disciples attended a wedding in Cana of Galilee. When the wine ran out, Mary told Jesus about the problem. He replied, 'Woman, why do you involve me? My hour has not yet come.' Yet Mary told the servants, 'Do whatever he tells you.' Jesus had six stone water jars filled with water. He told the servants to draw some out and take it to the master of the banquet. The water had become wine. The master did not know where it came from but called it the best wine. John notes this was the first of Jesus' signs, through which He revealed His glory.",
        keyVerse: "What Jesus did here in Cana of Galilee was the first of the signs through which he revealed his glory. — John 2:11",
        questions: [
          { question: "How many stone water jars were filled?", options: ["Two","Four","Six","Twelve"], correct: 2, explanation: "John 2:6 says there were six stone water jars of the kind used for Jewish ceremonial washing." },
          { question: "Who told Jesus about the problem with the wine?", options: ["A servant","A wedding guest","Mary, His mother","The master of the banquet"], correct: 2, explanation: "John 2:3 says when the wine was gone, Jesus' mother said to him 'They have no more wine.'" },
          { question: "What did Mary tell the servants?", options: ["Go buy more wine","Wait for a miracle","Do whatever he tells you","Tell the host about the problem"], correct: 2, explanation: "John 2:5 records Mary's instruction to the servants: 'Do whatever he tells you.'" }
        ]
      },
      {
        id: "miracle-2",
        title: "Jesus Heals the Blind Man",
        scripture: "John 9:1-41",
        teaching: "Jesus saw a man who had been blind from birth. His disciples asked whose sin caused the blindness — the man's or his parents'. Jesus said neither; this happened so the works of God might be displayed in him. Jesus spat on the ground, made mud, and put it on the man's eyes, telling him to wash in the Pool of Siloam. The man went and washed, and came home seeing. The Pharisees were troubled because Jesus healed on the Sabbath. When questioned, the man said, 'One thing I do know. I was blind but now I see!' He later worshiped Jesus.",
        keyVerse: "One thing I do know. I was blind but now I see! — John 9:25",
        questions: [
          { question: "According to Jesus, why was the man born blind?", options: ["Because of his own sin","Because of his parents' sin","So that the works of God might be displayed in him","As a test of Israel's faith"], correct: 2, explanation: "John 9:3 says Jesus answered 'Neither this man nor his parents sinned... this happened so that the works of God might be displayed in him.'" },
          { question: "What did Jesus do to heal the blind man?", options: ["Said a prayer and touched his eyes","Made mud and put it on his eyes, then told him to wash","Simply commanded him to see","Touched his forehead"], correct: 1, explanation: "John 9:6-7 says Jesus made mud, put it on the man's eyes, and told him to wash in the Pool of Siloam." },
          { question: "What was the blind man's famous response to the Pharisees?", options: ["I do not understand what happened","Jesus is the Messiah","One thing I do know — I was blind but now I see","Please leave me alone"], correct: 2, explanation: "John 9:25 records his bold testimony: 'One thing I do know. I was blind but now I see!'" }
        ]
      },
      {
        id: "miracle-3",
        title: "The Raising of Lazarus",
        scripture: "John 11:1-44",
        teaching: "Lazarus, a dear friend of Jesus and brother of Mary and Martha, became sick. Jesus delayed coming for two days, saying 'This sickness will not end in death. No, it is for God's glory.' By the time Jesus arrived, Lazarus had been in the tomb four days. Martha said, 'Lord, if you had been here, my brother would not have died.' Jesus told her, 'I am the resurrection and the life. The one who believes in me will live, even though they die.' Jesus wept. Then He called out, 'Lazarus, come out!' and Lazarus walked out of the tomb, still wrapped in burial cloths. Many people believed in Jesus.",
        keyVerse: "I am the resurrection and the life. The one who believes in me will live, even though they die. — John 11:25",
        questions: [
          { question: "How long had Lazarus been in the tomb?", options: ["One day","Two days","Three days","Four days"], correct: 3, explanation: "John 11:17 says when Jesus arrived, Lazarus had already been in the tomb for four days." },
          { question: "What is the shortest verse in the Bible found in this passage?", options: ["God is love","Pray always","Jesus wept","Be still"], correct: 2, explanation: "John 11:35 — 'Jesus wept' — is widely considered the shortest verse in the Bible, showing Jesus' genuine compassion." },
          { question: "What did Jesus say to call Lazarus out of the tomb?", options: ["Rise and be healed","Come forth into light","Lazarus, come out!","Be raised in the name of God"], correct: 2, explanation: "John 11:43 says 'Jesus called in a loud voice, Lazarus, come out!' — and the dead man came out." }
        ]
      },
      {
        id: "miracle-4",
        title: "Jesus Walks on Water",
        scripture: "Matthew 14:22-33",
        teaching: "After feeding the five thousand, Jesus sent His disciples ahead by boat while He went up alone to pray. Late at night a fierce storm arose. Jesus came walking on the water toward them. The disciples were terrified, thinking He was a ghost. Jesus said, 'Take courage! It is I. Don't be afraid.' Peter asked to come to Jesus on the water. Jesus said, 'Come.' Peter stepped out and walked on water — but when he saw the wind, he was afraid and began to sink. He cried out, 'Lord, save me!' Jesus reached out His hand and said, 'You of little faith, why did you doubt?'",
        keyVerse: "Immediately Jesus reached out his hand and caught him. 'You of little faith,' he said, 'why did you doubt?' — Matthew 14:31",
        questions: [
          { question: "What was Jesus doing when the storm struck?", options: ["Sleeping on the boat","Preaching to the crowds","Praying alone on the mountain","Traveling to another town"], correct: 2, explanation: "Matthew 14:23 says Jesus went up on a mountainside by himself to pray." },
          { question: "What happened when Peter took his eyes off Jesus?", options: ["He walked faster","He stopped walking","He sank","He turned back to the boat"], correct: 2, explanation: "Matthew 14:30 says 'when he saw the wind, he was afraid and, beginning to sink, cried out, Lord, save me!'" },
          { question: "What did the disciples do after Jesus calmed the storm?", options: ["They fell asleep","They worshiped Jesus saying 'Truly you are the Son of God'","They asked for more miracles","They wrote down what happened"], correct: 1, explanation: "Matthew 14:33 says 'Then those who were in the boat worshiped him, saying, Truly you are the Son of God.'" }
        ]
      },
      {
        id: "miracle-5",
        title: "The Healing of the Ten Lepers",
        scripture: "Luke 17:11-19",
        teaching: "As Jesus traveled along the border between Samaria and Galilee, ten men who had leprosy stood at a distance and called out, 'Jesus, Master, have pity on us!' Jesus told them to go and show themselves to the priests. As they went, they were cleansed. One of them, when he saw he was healed, came back, praising God in a loud voice. He threw himself at Jesus' feet and thanked Him — and he was a Samaritan. Jesus asked, 'Were not all ten cleansed? Where are the other nine? Has no one returned to give praise to God except this foreigner?' Jesus told him to rise — his faith had made him well.",
        keyVerse: "Were not all ten cleansed? Where are the other nine? — Luke 17:17",
        questions: [
          { question: "How many lepers were healed?", options: ["One","Three","Ten","Seven"], correct: 2, explanation: "Luke 17:12 says ten men who had leprosy met Jesus and asked for His mercy." },
          { question: "How many lepers returned to thank Jesus?", options: ["All ten","Seven","Three","One"], correct: 3, explanation: "Luke 17:15 says only one of them came back when he saw he was healed." },
          { question: "What was notable about the one who returned?", options: ["He was a priest","He was a disciple of John","He was a Samaritan — a foreigner","He was the youngest"], correct: 2, explanation: "Luke 17:16 says he was a Samaritan. Jesus highlighted this, pointing out that a foreigner showed more gratitude than the nine Jews." }
        ]
      }
    ]
  },

  // ─── PSALMS & WISDOM ──────────────────────────────────────────────────────
  {
    id: "psalms-wisdom",
    title: "Psalms & Wisdom",
    description: "Songs and wise sayings",
    icon: "📖",
    color: "from-sky-500 to-blue-600",
    lessons: [
      {
        id: "wisdom-1",
        title: "Psalm 23 — The Good Shepherd",
        scripture: "Psalm 23",
        teaching: "David wrote this beloved psalm declaring the Lord as his shepherd. Because the Lord is his shepherd, David lacks nothing. God makes him lie down in green pastures, leads him beside quiet waters, and restores his soul. Even walking through the valley of the shadow of death, David fears no evil because God is with him. God's rod and staff comfort him. God prepares a table before him in the presence of his enemies, anoints his head with oil, and his cup overflows. Goodness and love will follow him all his days.",
        keyVerse: "The Lord is my shepherd, I lack nothing. — Psalm 23:1",
        questions: [
          { question: "Who wrote Psalm 23?", options: ["Moses","Solomon","David","Paul"], correct: 2, explanation: "Psalm 23 is attributed to David, who was himself a shepherd before becoming king of Israel." },
          { question: "What does David say he will not fear in the valley of the shadow of death?", options: ["Loneliness","Hunger","Evil","Darkness"], correct: 2, explanation: "Psalm 23:4 says 'Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me.'" },
          { question: "What does God prepare in the presence of David's enemies?", options: ["A weapon","A table","A shield","An army"], correct: 1, explanation: "Psalm 23:5 says 'You prepare a table before me in the presence of my enemies.'" }
        ]
      },
      {
        id: "wisdom-2",
        title: "Proverbs on Wisdom and Foolishness",
        scripture: "Proverbs 1-4; 9",
        teaching: "The book of Proverbs declares 'The fear of the Lord is the beginning of wisdom.' Wisdom is personified as a woman calling out in the streets, inviting people to learn her ways. The wise person listens to instruction, accepts correction, and guards their heart. The foolish person rejects discipline, goes their own way, and faces ruin. Proverbs 3 urges us to trust in the Lord with all our heart and not lean on our own understanding, to acknowledge Him in all our ways so He will direct our paths.",
        keyVerse: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight. — Proverbs 3:5-6",
        questions: [
          { question: "According to Proverbs, what is the beginning of wisdom?", options: ["Reading many books","The fear of the Lord","Having good parents","Years of experience"], correct: 1, explanation: "Proverbs 1:7 and 9:10 both declare 'The fear of the Lord is the beginning of wisdom.'" },
          { question: "What does Proverbs 3:5 say we should not lean on?", options: ["Our neighbors","Our own understanding","Worldly wealth","Human leaders"], correct: 1, explanation: "Proverbs 3:5 says 'Trust in the Lord with all your heart and lean not on your own understanding.'" },
          { question: "According to Proverbs 4:23, what should we guard above all else?", options: ["Our money","Our reputation","Our heart","Our time"], correct: 2, explanation: "Proverbs 4:23 says 'Above all else, guard your heart, for everything you do flows from it.'" }
        ]
      },
      {
        id: "wisdom-3",
        title: "Psalm 51 — A Prayer of Repentance",
        scripture: "Psalm 51",
        teaching: "David wrote this psalm after the prophet Nathan confronted him about his sin with Bathsheba and the murder of Uriah. He cries out: 'Have mercy on me, O God, according to your unfailing love.' He acknowledges that sin is ultimately against God, asks for a clean heart and renewed spirit, and prays that God would not take His Holy Spirit from him. He promises that a broken and contrite heart God will not despise. This psalm has guided countless believers in confession and repentance.",
        keyVerse: "Create in me a pure heart, O God, and renew a steadfast spirit within me. — Psalm 51:10",
        questions: [
          { question: "What event prompted David to write Psalm 51?", options: ["His battle with Goliath","Nathan confronting him about his sin with Bathsheba","The death of his son Absalom","His coronation as king"], correct: 1, explanation: "The superscription of Psalm 51 says it was written 'when the prophet Nathan came to him after David had committed adultery with Bathsheba.'" },
          { question: "What does David ask God not to take from him?", options: ["His kingdom","His family","Your Holy Spirit","His life"], correct: 2, explanation: "David prays in Psalm 51:11 'Do not cast me from your presence or take your Holy Spirit from me.'" },
          { question: "What kind of sacrifice does David say God desires?", options: ["Burnt offerings","Gold and silver","A broken and contrite heart","Public fasting"], correct: 2, explanation: "Psalm 51:17 says 'My sacrifice, O God, is a broken spirit; a broken and contrite heart you, God, will not despise.'" }
        ]
      },
      {
        id: "wisdom-4",
        title: "Ecclesiastes — Meaning and Vanity",
        scripture: "Ecclesiastes 1-3; 12",
        teaching: "The Preacher (traditionally Solomon) declares 'Vanity of vanities, all is vanity!' He explored every pleasure, wisdom, work, and wealth the world offers, yet found that without God, everything is meaningless — like chasing the wind. One of the most beautiful passages describes seasons of life: 'There is a time for everything — a time to be born and a time to die.' The book concludes with ultimate wisdom: 'Fear God and keep his commandments, for this is the duty of all mankind.'",
        keyVerse: "Fear God and keep his commandments, for this is the duty of all mankind. — Ecclesiastes 12:13",
        questions: [
          { question: "What does 'vanity of vanities, all is vanity' mean?", options: ["Everything is beautiful","Life without God is empty and meaningless","Humans are vain and proud","Only youth has value"], correct: 1, explanation: "The Hebrew 'hebel' means vapor or breath — pursuing worldly things apart from God leaves life empty and purposeless." },
          { question: "What does Ecclesiastes 3 famously describe?", options: ["The creation of the world","The laws of Moses","Seasons and appointed times for everything in life","The judgment of God"], correct: 2, explanation: "Ecclesiastes 3:1-8 poetically describes 'a time for everything, and a season for every activity under the heavens.'" },
          { question: "What is the final conclusion of Ecclesiastes?", options: ["Enjoy life while you can","Wisdom is the greatest treasure","Fear God and keep his commandments","Wealth brings happiness"], correct: 2, explanation: "Ecclesiastes 12:13 concludes: 'Fear God and keep his commandments, for this is the duty of all mankind.'" }
        ]
      },
      {
        id: "wisdom-5",
        title: "Psalm 119 — The Word of God",
        scripture: "Psalm 119",
        teaching: "Psalm 119 is the longest chapter in the Bible — 176 verses organized around the Hebrew alphabet. Nearly every verse mentions the word of God using eight different terms: law, statutes, precepts, commands, decrees, ways, word, and promises. The psalmist declares that God's word is a lamp to his feet and a light to his path. He hides God's word in his heart so he might not sin against God. He meditates on it day and night. This psalm teaches us that Scripture is not merely information but nourishment, light, and guidance for daily life.",
        keyVerse: "Your word is a lamp for my feet, a light on my path. — Psalm 119:105",
        questions: [
          { question: "Why is Psalm 119 unique?", options: ["It was written by Jesus","It is the longest chapter in the Bible, organized around the Hebrew alphabet","It contains 10 commandments","It was sung at the temple only"], correct: 1, explanation: "Psalm 119 has 176 verses, making it the longest chapter in the Bible. It is an acrostic poem with 22 sections corresponding to each letter of the Hebrew alphabet." },
          { question: "How does the psalmist use God's word to avoid sin?", options: ["By reading it publicly","By reciting it in the temple","By hiding it in his heart","By writing it on scrolls"], correct: 2, explanation: "Psalm 119:11 says 'I have hidden your word in my heart that I might not sin against you.'" },
          { question: "What does the psalmist say he does with God's word day and night?", options: ["Recites it aloud","Argues about it","Meditates on it","Teaches it to others"], correct: 2, explanation: "Psalm 119:97 says 'Oh, how I love your law! I meditate on it all day long.'" }
        ]
      },
      {
        id: "wisdom-6",
        title: "Psalm 139 — God Knows Me Completely",
        scripture: "Psalm 139",
        teaching: "David meditates on God's all-encompassing knowledge. God knows when David sits and when he rises; He perceives his thoughts from afar; He is familiar with all his ways. Before a word is on David's tongue, God knows it completely. There is nowhere David can go to flee from God's Spirit — not into the heavens, the depths, or the far ends of the sea; God is there. David marvels that he is fearfully and wonderfully made. God saw his unformed body and ordained all his days before one of them came to be. David closes by asking God to search him, know his anxious thoughts, and lead him in the everlasting way.",
        keyVerse: "I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well. — Psalm 139:14",
        questions: [
          { question: "What does Psalm 139:14 say about human beings?", options: ["We are made from dust and will return to dust","We are fearfully and wonderfully made","We are sinful from birth","We are made lower than angels"], correct: 1, explanation: "Psalm 139:14 says 'I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well.'" },
          { question: "What does Psalm 139 teach about God's omnipresence?", options: ["God only lives in heaven","God is only in places of worship","There is nowhere you can flee from God's Spirit","God is absent in darkness"], correct: 2, explanation: "Psalm 139:7-10 says whether David goes to the heavens, the depths, or the far side of the sea, God is there." },
          { question: "What does David ask God to do at the end of Psalm 139?", options: ["Destroy his enemies","Give him wealth","Search him and know his anxious thoughts, and lead him","Reveal the future to him"], correct: 2, explanation: "Psalm 139:23-24 closes with 'Search me, God, and know my heart; test me and know my anxious thoughts. See if there is any offensive way in me, and lead me in the way everlasting.'" }
        ]
      }
    ]
  },

  // ─── DEATH & RESURRECTION ─────────────────────────────────────────────────
  {
    id: "resurrection",
    title: "Death & Resurrection",
    description: "The heart of the Gospel",
    icon: "🕊️",
    color: "from-yellow-500 to-amber-600",
    lessons: [
      {
        id: "resurrection-1",
        title: "The Crucifixion",
        scripture: "Matthew 27:32-56",
        teaching: "Jesus was led to Golgotha (The Place of the Skull) and crucified between two criminals. From noon until three in the afternoon, darkness covered the land. Jesus cried out, 'My God, my God, why have you forsaken me?' — quoting Psalm 22. When Jesus gave up His spirit, the curtain of the temple was torn in two from top to bottom, the earth shook, and tombs broke open. The centurion exclaimed, 'Surely he was the Son of God!' Jesus' death fulfilled prophecy and opened the way for humanity's redemption.",
        keyVerse: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. — John 3:16",
        questions: [
          { question: "What happened to the temple curtain when Jesus died?", options: ["It caught fire","It was torn in two","Nothing","It turned white"], correct: 1, explanation: "Matthew 27:51 says 'the curtain of the temple was torn in two from top to bottom,' symbolizing open access to God." },
          { question: "What did the centurion say about Jesus?", options: ["He was innocent","Surely he was the Son of God","He was a prophet","He was a king"], correct: 1, explanation: "Matthew 27:54 records the centurion saying 'Surely he was the Son of God!'" },
          { question: "Where was Jesus crucified?", options: ["Mount Sinai","Bethlehem","Golgotha","Nazareth"], correct: 2, explanation: "Matthew 27:33 says they came to 'a place called Golgotha (which means the place of the skull).'" }
        ]
      },
      {
        id: "resurrection-2",
        title: "He Is Risen",
        scripture: "Matthew 28:1-10",
        teaching: "On the first day of the week, Mary Magdalene and the other Mary went to the tomb. There was a violent earthquake as an angel of the Lord rolled back the stone and sat on it. His appearance was like lightning. The guards were so afraid they became like dead men. The angel told the women, 'Do not be afraid, for I know that you are looking for Jesus, who was crucified. He is not here; he has risen, just as he said.' Jesus then appeared to them, and they worshiped Him.",
        keyVerse: "He is not here; he has risen, just as he said. — Matthew 28:6",
        questions: [
          { question: "Who first discovered the empty tomb?", options: ["Peter and John","The disciples","Mary Magdalene and the other Mary","The Roman guards"], correct: 2, explanation: "Matthew 28:1 says 'Mary Magdalene and the other Mary went to look at the tomb.'" },
          { question: "What did the angel say to the women?", options: ["Go away","He is not here; he has risen","Wait here","Do not enter"], correct: 1, explanation: "Matthew 28:6 records the angel saying 'He is not here; he has risen, just as he said.'" },
          { question: "On what day did the resurrection occur?", options: ["The Sabbath","The first day of the week","Friday","The third month"], correct: 1, explanation: "Matthew 28:1 says 'After the Sabbath, at dawn on the first day of the week.'" }
        ]
      },
      {
        id: "resurrection-3",
        title: "The Road to Emmaus",
        scripture: "Luke 24:13-35",
        teaching: "On the day of the resurrection, two disciples were walking to Emmaus, discussing all that had happened. Jesus came alongside them, but they were kept from recognizing Him. As they walked, He explained from Moses and all the Prophets how the Messiah had to suffer and enter His glory. When He took bread, gave thanks, and broke it, their eyes were opened — and He vanished. They rushed back to Jerusalem saying 'It is true! The Lord has risen!' Jesus had explained how all of Scripture pointed to Him.",
        keyVerse: "Did not our hearts burn within us while he talked with us on the road, while he opened to us the Scriptures? — Luke 24:32",
        questions: [
          { question: "Where were the two disciples going when Jesus joined them?", options: ["Bethlehem","Nazareth","Emmaus","Galilee"], correct: 2, explanation: "Luke 24:13 says 'two of them were going to a village called Emmaus, about seven miles from Jerusalem.'" },
          { question: "When did the disciples recognize Jesus?", options: ["When He spoke to them","When He healed a blind man","When He broke bread with them","When He showed His wounds"], correct: 2, explanation: "Luke 24:30-31 says when He broke bread and gave it to them, their eyes were opened and they recognized Him." },
          { question: "What did Jesus explain on the road to Emmaus?", options: ["Future prophecies","The Ten Commandments","How Moses and all the Prophets pointed to the Messiah","His childhood in Nazareth"], correct: 2, explanation: "Luke 24:27 says 'beginning with Moses and all the Prophets, he explained to them what was said in all the Scriptures concerning himself.'" }
        ]
      },
      {
        id: "resurrection-4",
        title: "The Great Commission",
        scripture: "Matthew 28:16-20",
        teaching: "After His resurrection, Jesus appeared to His eleven remaining disciples on a mountain in Galilee. Some worshiped Him, but some doubted. Jesus came to them and said, 'All authority in heaven and on earth has been given to me. Therefore go and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit, and teaching them to obey everything I have commanded you.' He sealed this with the most comforting promise: 'And surely I am with you always, to the very end of the age.'",
        keyVerse: "Therefore go and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit. — Matthew 28:19",
        questions: [
          { question: "What authority did Jesus claim before giving the Great Commission?", options: ["Authority over Israel alone","Authority over His disciples","All authority in heaven and on earth","Authority given by the Jewish leaders"], correct: 2, explanation: "Matthew 28:18 says 'All authority in heaven and on earth has been given to me.'" },
          { question: "What three things does the Great Commission command?", options: ["Pray, fast, worship","Go, make disciples, baptize and teach","Preach, heal, cast out demons","Study, memorize, obey"], correct: 1, explanation: "Matthew 28:19-20 commands going, making disciples of all nations, baptizing them, and teaching them to obey Christ's commands." },
          { question: "What promise did Jesus give at the end of the Great Commission?", options: ["He would return within a generation","He would send an angel to guide them","He would be with them always to the end of the age","He would give them miraculous powers"], correct: 2, explanation: "Matthew 28:20 ends with Jesus' promise: 'And surely I am with you always, to the very end of the age.'" }
        ]
      },
      {
        id: "resurrection-5",
        title: "Pentecost and the Holy Spirit",
        scripture: "Acts 2:1-41",
        teaching: "After Jesus ascended into heaven, His disciples waited in Jerusalem. On the day of Pentecost they were all together when suddenly a sound like a violent wind filled the house and tongues of fire rested on each of them. They were filled with the Holy Spirit and began speaking in other languages. Jews from every nation heard them in their own language. Peter preached boldly, explaining that Jesus had been crucified, raised, and exalted. He called the crowd to repent and be baptized in Jesus' name. About three thousand people believed that day.",
        keyVerse: "Repent and be baptized, every one of you, in the name of Jesus Christ for the forgiveness of your sins. And you will receive the gift of the Holy Spirit. — Acts 2:38",
        questions: [
          { question: "What appeared on each of the disciples at Pentecost?", options: ["Crowns of gold","Tongues of fire","White robes","Wings like eagles"], correct: 1, explanation: "Acts 2:3 says 'They saw what seemed to be tongues of fire that separated and came to rest on each of them.'" },
          { question: "How many people were added to the church on the day of Pentecost?", options: ["Seventy","Five hundred","Three thousand","Ten thousand"], correct: 2, explanation: "Acts 2:41 says 'About three thousand were added to their number that day.'" },
          { question: "What did Peter call the crowd to do in Acts 2:38?", options: ["Fast for forty days","Build a temple","Repent and be baptized in Jesus' name","Leave Jerusalem"], correct: 2, explanation: "Peter said 'Repent and be baptized, every one of you, in the name of Jesus Christ for the forgiveness of your sins, and you will receive the gift of the Holy Spirit.'" }
        ]
      }
    ]
  },

  // ─── ACTS OF THE APOSTLES ─────────────────────────────────────────────────
  {
    id: "acts",
    title: "Acts of the Apostles",
    description: "The birth of the early church",
    icon: "🌐",
    color: "from-orange-500 to-red-500",
    lessons: [
      {
        id: "acts-1",
        title: "The Conversion of Paul",
        scripture: "Acts 9:1-31",
        teaching: "Saul of Tarsus was zealously persecuting followers of Jesus, breathing out murderous threats against them. He obtained letters from the high priest and was traveling to Damascus to arrest believers when a light from heaven suddenly flashed around him. He fell to the ground and heard a voice: 'Saul, Saul, why do you persecute me?' He asked who was speaking and the voice replied, 'I am Jesus, whom you are persecuting.' Saul was blinded for three days and did not eat or drink. God sent a disciple named Ananias to restore his sight and baptize him. Saul — later renamed Paul — became the greatest missionary in history.",
        keyVerse: "Saul, Saul, why do you persecute me? — Acts 9:4",
        questions: [
          { question: "What was Paul doing when Jesus appeared to him?", options: ["Praying in the temple","Traveling to Damascus to arrest believers","Preaching in a synagogue","Reading the Scriptures"], correct: 1, explanation: "Acts 9:1-3 says Saul was traveling to Damascus to arrest followers of Jesus when a light from heaven struck him." },
          { question: "How long was Paul blinded after the encounter?", options: ["One day","Three days","Seven days","Forty days"], correct: 1, explanation: "Acts 9:9 says 'For three days he was blind, and did not eat or drink anything.'" },
          { question: "Who did God send to restore Paul's sight?", options: ["Peter","Stephen","Barnabas","Ananias"], correct: 3, explanation: "Acts 9:10-18 records God sending a disciple named Ananias to pray for Saul, after which something like scales fell from his eyes." }
        ]
      },
      {
        id: "acts-2",
        title: "Peter and Cornelius",
        scripture: "Acts 10",
        teaching: "Cornelius, a Roman centurion who feared God, received a vision of an angel telling him to send for Peter. Peter also received a vision: a sheet descended from heaven containing all kinds of animals, and a voice said, 'Rise, Peter. Kill and eat.' Peter refused, saying he had never eaten anything impure. The voice replied, 'Do not call anything impure that God has made clean.' This happened three times. Then Cornelius's men arrived. Peter understood God was showing him that the gospel was for all people, not just Jews. He preached at Cornelius's house, and the Holy Spirit fell on all the Gentiles present.",
        keyVerse: "I now realize how true it is that God does not show favoritism but accepts from every nation the one who fears him and does what is right. — Acts 10:34-35",
        questions: [
          { question: "What did Peter's vision of the sheet teach him?", options: ["Which foods were clean","That all foods were now allowed","That God accepts people from every nation — not just Jews","That Gentiles should become Jews first"], correct: 2, explanation: "Acts 10:28 says Peter understood 'God has shown me that I should not call any person impure or unclean.'" },
          { question: "Who was Cornelius?", options: ["A Jewish priest","A Roman centurion who feared God","A Greek philosopher","A Samaritan merchant"], correct: 1, explanation: "Acts 10:1-2 describes Cornelius as 'a centurion in what was known as the Italian Regiment... He and all his family were devout and God-fearing.'" },
          { question: "What happened while Peter was preaching at Cornelius's house?", options: ["An earthquake struck","The Holy Spirit fell on all who heard the message","Peter was arrested","They all saw a vision of Jesus"], correct: 1, explanation: "Acts 10:44 says 'While Peter was still speaking these words, the Holy Spirit came on all who heard the message.'" }
        ]
      },
      {
        id: "acts-3",
        title: "Paul's First Missionary Journey",
        scripture: "Acts 13-14",
        teaching: "The Holy Spirit set apart Barnabas and Saul for the work He had called them to. They sailed to Cyprus and then to Asia Minor (modern-day Turkey), preaching in synagogues and establishing churches. In Lystra, Paul healed a man lame from birth, and the crowd tried to worship him and Barnabas as gods. Paul and Barnabas tore their clothes and declared they were only ordinary men. Paul was later stoned by opponents and left for dead, but got up and continued. They returned strengthening the disciples and reminding them: 'We must go through many hardships to enter the kingdom of God.'",
        keyVerse: "We must go through many hardships to enter the kingdom of God. — Acts 14:22",
        questions: [
          { question: "How was Paul and Barnabas sent out on their journey?", options: ["The Jerusalem council appointed them","The Holy Spirit said 'Set apart Barnabas and Saul for the work I have called them to'","Paul volunteered and chose Barnabas","The church in Rome commissioned them"], correct: 1, explanation: "Acts 13:2 says 'The Holy Spirit said, Set apart for me Barnabas and Saul for the work to which I have called them.'" },
          { question: "What did the crowd in Lystra want to do to Paul and Barnabas?", options: ["Arrest them","Worship them as gods","Send them away","Make them kings"], correct: 1, explanation: "Acts 14:11-13 says the crowd called Barnabas Zeus and Paul Hermes and wanted to offer sacrifices to them." },
          { question: "What happened to Paul in Lystra?", options: ["He was arrested","He performed a great miracle","He was stoned and left for dead","He got very sick"], correct: 2, explanation: "Acts 14:19 says Jews from Antioch and Iconium stoned Paul and dragged him outside the city, thinking he was dead." }
        ]
      },
      {
        id: "acts-4",
        title: "Paul in Prison — Singing at Midnight",
        scripture: "Acts 16:16-40",
        teaching: "Paul and Silas were beaten with rods and thrown into prison in Philippi for casting a demon out of a slave girl. At midnight Paul and Silas were praying and singing hymns to God, and the other prisoners were listening. Suddenly there was a violent earthquake that opened all the doors and loosed everyone's chains. The jailer, thinking the prisoners had escaped, was about to kill himself when Paul called out, 'Don't harm yourself! We are all here!' The jailer asked, 'What must I do to be saved?' Paul and Silas replied, 'Believe in the Lord Jesus, and you will be saved — you and your household.' The jailer and his whole family believed and were baptized.",
        keyVerse: "Believe in the Lord Jesus, and you will be saved — you and your household. — Acts 16:31",
        questions: [
          { question: "What were Paul and Silas doing at midnight in prison?", options: ["Sleeping","Planning an escape","Praying and singing hymns to God","Writing letters"], correct: 2, explanation: "Acts 16:25 says 'About midnight Paul and Silas were praying and singing hymns to God, and the other prisoners were listening to them.'" },
          { question: "What opened the prison doors?", options: ["An angel appeared","The disciples broke them out","A violent earthquake","The jailer opened them"], correct: 2, explanation: "Acts 16:26 says 'suddenly there was such a violent earthquake that the foundations of the prison were shaken. At once all the prison doors flew open.'" },
          { question: "What did the jailer ask Paul and Silas?", options: ["Why did you not escape?","What must I do to be saved?","Are you prophets?","Can you heal my family?"], correct: 1, explanation: "Acts 16:30 records the jailer asking 'Sirs, what must I do to be saved?'" }
        ]
      },
      {
        id: "acts-5",
        title: "Paul Before King Agrippa",
        scripture: "Acts 26",
        teaching: "Paul was in Roman custody and was brought before King Agrippa II. Paul gave an impassioned defense of his faith, sharing his personal testimony of encountering Jesus on the road to Damascus. He explained how Jesus called him to open people's eyes, turn them from darkness to light, and from the power of Satan to God. Governor Festus interrupted: 'You are out of your mind, Paul! Your great learning is driving you insane.' Paul responded calmly and turned to Agrippa: 'King Agrippa, do you believe the prophets?' Agrippa replied, 'Do you think that in such a short time you can persuade me to be a Christian?' Paul said he prayed everyone hearing him might become what he was — except the chains.",
        keyVerse: "I pray God that not only you but all who are listening to me today may become what I am, except for these chains. — Acts 26:29",
        questions: [
          { question: "What was the main content of Paul's defense before Agrippa?", options: ["An argument about Jewish law","His personal testimony of encountering Jesus on the road to Damascus","A political argument for Rome","A critique of the high priest"], correct: 1, explanation: "Acts 26:12-23 describes Paul sharing his dramatic encounter with Jesus on the Damascus road and his call to preach to the Gentiles." },
          { question: "What did Governor Festus accuse Paul of?", options: ["Treason","Blasphemy","Being insane from too much learning","Practicing magic"], correct: 2, explanation: "Acts 26:24 says Festus interrupted: 'You are out of your mind, Paul! Your great learning is driving you insane.'" },
          { question: "What was Paul's prayer for those listening to him?", options: ["That they would let him go free","That they would join Rome","That all might become what he was except for the chains","That they would believe in the resurrection"], correct: 2, explanation: "Acts 26:29 says 'I pray God that not only you but all who are listening to me today may become what I am, except for these chains.'" }
        ]
      }
    ]
  },

  // ─── PAUL'S LETTERS ───────────────────────────────────────────────────────
  {
    id: "pauls-letters",
    title: "Paul's Letters",
    description: "Epistles to the churches",
    icon: "✉️",
    color: "from-teal-500 to-cyan-600",
    lessons: [
      {
        id: "paul-1",
        title: "Romans — Justified by Faith",
        scripture: "Romans 3; 5; 8",
        teaching: "Paul's letter to the Romans is the most systematic presentation of the Gospel. He argues that all people — Jew and Gentile — have sinned and fall short of God's glory. But God demonstrates His love in that while we were still sinners, Christ died for us. We are justified (declared righteous) by faith in Jesus, not by works. Romans 8 declares there is now no condemnation for those who are in Christ Jesus. And nothing in all creation can separate us from the love of God in Christ Jesus our Lord.",
        keyVerse: "For all have sinned and fall short of the glory of God, and all are justified freely by his grace through the redemption that came by Christ Jesus. — Romans 3:23-24",
        questions: [
          { question: "According to Romans 3:23, who has sinned?", options: ["Only Gentiles","Mostly Israelites","All people","Only non-believers"], correct: 2, explanation: "Romans 3:23 says 'for all have sinned and fall short of the glory of God.'" },
          { question: "When did God demonstrate His love for us according to Romans 5:8?", options: ["When we became good people","When we followed the Law","While we were still sinners","After the resurrection"], correct: 2, explanation: "Romans 5:8 says 'God demonstrates his own love for us in this: While we were still sinners, Christ died for us.'" },
          { question: "What does Romans 8:1 declare for those who are in Christ Jesus?", options: ["They will never suffer","There is no condemnation","They are perfect","They will never face temptation"], correct: 1, explanation: "Romans 8:1 says 'Therefore, there is now no condemnation for those who are in Christ Jesus.'" }
        ]
      },
      {
        id: "paul-2",
        title: "The Fruit of the Spirit",
        scripture: "Galatians 5:16-26",
        teaching: "Paul writes to the Galatians that those who walk by the Spirit will not gratify the desires of the flesh. The works of the flesh include immorality, discord, jealousy, fits of rage. But the fruit of the Spirit — produced when we live in step with the Holy Spirit — is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, and self-control. Against such things there is no law. Those who belong to Christ Jesus have crucified the flesh with its passions.",
        keyVerse: "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness and self-control. — Galatians 5:22-23",
        questions: [
          { question: "How many qualities are listed as the fruit of the Spirit in Galatians 5?", options: ["7","9","12","5"], correct: 1, explanation: "Galatians 5:22-23 lists nine qualities: love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, and self-control." },
          { question: "What does Paul say about the law in relation to the fruit of the Spirit?", options: ["The law commands these things","Against such things there is no law","The law opposes the Spirit","The law equals the Spirit"], correct: 1, explanation: "Galatians 5:23 ends with 'Against such things there is no law.'" },
          { question: "What must we do according to Galatians 5:25?", options: ["Memorize Scripture","Keep in step with the Spirit","Observe Jewish festivals","Avoid all worldly contact"], correct: 1, explanation: "Galatians 5:25 says 'Since we live by the Spirit, let us keep in step with the Spirit.'" }
        ]
      },
      {
        id: "paul-3",
        title: "Faith, Hope, and Love",
        scripture: "1 Corinthians 13",
        teaching: "Paul wrote to the divided Corinthian church about the supremacy of love. Even if someone could speak in tongues of angels, had the gift of prophecy, understood all mysteries and knowledge, had faith to move mountains, or gave away everything they had — without love, it would be nothing. Love is patient, love is kind. It does not envy, does not boast, is not proud, is not self-seeking, is not easily angered, keeps no record of wrongs. Love never fails. The greatest of all is love.",
        keyVerse: "And now these three remain: faith, hope and love. But the greatest of these is love. — 1 Corinthians 13:13",
        questions: [
          { question: "According to 1 Corinthians 13, what is worthless without love?", options: ["Only prophecy","Only wealth","Even speaking in tongues, prophecy, knowledge, and great faith","Only fasting"], correct: 2, explanation: "Paul says that speaking in tongues, prophecy, knowledge, and giving all you have without love profits nothing." },
          { question: "What does Paul say love never does?", options: ["Never commands","Never fails","Never speaks loudly","Never judges"], correct: 1, explanation: "1 Corinthians 13:8 says 'Love never fails. But where there are prophecies, they will cease; where there are tongues, they will be stilled.'" },
          { question: "What is the greatest of faith, hope, and love?", options: ["Faith","Hope","Love","All are equal"], correct: 2, explanation: "1 Corinthians 13:13 concludes 'And now these three remain: faith, hope and love. But the greatest of these is love.'" }
        ]
      },
      {
        id: "paul-4",
        title: "The Armor of God",
        scripture: "Ephesians 6:10-18",
        teaching: "Paul urges believers to put on the full armor of God to stand against the schemes of the devil. Our struggle is not against flesh and blood but against spiritual forces of evil in the heavenly realms. The armor includes: the belt of truth, the breastplate of righteousness, feet fitted with the gospel of peace, the shield of faith to extinguish the flaming arrows of the evil one, the helmet of salvation, the sword of the Spirit which is the Word of God, and prayer in the Spirit.",
        keyVerse: "Put on the full armor of God, so that you can take your stand against the devil's schemes. — Ephesians 6:11",
        questions: [
          { question: "According to Paul, what is our struggle really against?", options: ["Other nations","Corrupt governments","Flesh and blood only","Spiritual forces of evil in heavenly realms"], correct: 3, explanation: "Ephesians 6:12 says 'our struggle is not against flesh and blood, but against the rulers, against the authorities, against the powers of this dark world.'" },
          { question: "What is the sword of the Spirit?", options: ["A physical weapon for battle","The Word of God","A sharp tongue","The Holy Spirit himself"], correct: 1, explanation: "Ephesians 6:17 identifies the sword of the Spirit as 'the word of God,' the one offensive weapon in the armor." },
          { question: "What is the shield of faith used for?", options: ["Defending the weak","To extinguish the flaming arrows of the evil one","To hide from enemies","To reflect God's glory"], correct: 1, explanation: "Ephesians 6:16 says 'take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one.'" }
        ]
      },
      {
        id: "paul-5",
        title: "Rejoice Always — Philippians",
        scripture: "Philippians 4:4-13",
        teaching: "Paul wrote the letter to the Philippians while in prison, yet it is the most joyful letter in the New Testament. He commands the church to 'Rejoice in the Lord always. I will say it again: Rejoice!' He urges them not to be anxious about anything but to present requests to God with thanksgiving, and the peace of God which transcends all understanding would guard their hearts. Paul shared the secret of contentment: 'I have learned, in whatever state I am, to be content.' Whether in need or in plenty, he could do all things through Christ who strengthened him.",
        keyVerse: "I can do all this through him who gives me strength. — Philippians 4:13",
        questions: [
          { question: "What does Paul command the Philippians to do instead of being anxious?", options: ["Fast and pray","Avoid all problems","Present requests to God with thanksgiving","Seek the advice of elders"], correct: 2, explanation: "Philippians 4:6 says 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.'" },
          { question: "What did Paul say guards our hearts and minds?", options: ["The Word of God","The Holy Spirit","The peace of God which transcends all understanding","Strong faith"], correct: 2, explanation: "Philippians 4:7 says 'the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.'" },
          { question: "What had Paul learned regarding his circumstances?", options: ["That suffering was meaningless","To be content in whatever state he was in","To always seek better conditions","To avoid hardship"], correct: 1, explanation: "Philippians 4:11-12 says 'I have learned the secret of being content in any and every situation, whether well fed or hungry.'" }
        ]
      },
      {
        id: "paul-6",
        title: "Colossians — Christ Is Supreme",
        scripture: "Colossians 1:15-23; 3:1-17",
        teaching: "Paul writes to the Colossian church warning them against false teachings. He exalts Christ as the image of the invisible God, the firstborn over all creation. In Christ all things were created; He is before all things and in Him all things hold together. He is the head of the body, the church, and He is the beginning and firstborn from among the dead. Paul urges the Colossians to set their minds on things above, not on earthly things. They have taken off the old self and put on the new self, renewed in knowledge in the image of its Creator. Whatever they do, in word or deed, do it all in the name of the Lord Jesus.",
        keyVerse: "The Son is the image of the invisible God, the firstborn over all creation. — Colossians 1:15",
        questions: [
          { question: "What does Paul call Jesus in Colossians 1:15?", options: ["The Son of David","The image of the invisible God","The greatest prophet","The new Moses"], correct: 1, explanation: "Colossians 1:15 says 'The Son is the image of the invisible God, the firstborn over all creation.'" },
          { question: "What does Paul say holds all things together?", options: ["God the Father","The Holy Spirit","The Law","Jesus Christ"], correct: 3, explanation: "Colossians 1:17 says 'He is before all things, and in him all things hold together.'" },
          { question: "What does Paul command about the things we do in Colossians 3:17?", options: ["Do only religious things","Do all things privately","Whatever you do in word or deed, do it all in the name of the Lord Jesus","Only do what the church elders approve"], correct: 2, explanation: "Colossians 3:17 says 'And whatever you do, whether in word or deed, do it all in the name of the Lord Jesus, giving thanks to God the Father through him.'" }
        ]
      }
    ]
  },

  // ─── GENERAL EPISTLES & REVELATION ───────────────────────────────────────
  {
    id: "general-epistles",
    title: "Epistles & Revelation",
    description: "James, Peter, John & Revelation",
    icon: "📜",
    color: "from-rose-500 to-pink-600",
    lessons: [
      {
        id: "epistle-1",
        title: "James — Faith Without Works Is Dead",
        scripture: "James 1-2",
        teaching: "James, the brother of Jesus, wrote a practical letter about living out faith. He begins by saying we should consider it pure joy when we face trials, because testing of faith produces perseverance. He warns about hearing the word without doing it — like someone who looks in a mirror and immediately forgets what they look like. The famous passage in James 2 challenges those who claim faith without works: 'What good is it if someone claims to have faith but has no deeds? Can such faith save them?' James argues that faith without works is dead. Genuine faith naturally produces action.",
        keyVerse: "Faith without deeds is dead. — James 2:26",
        questions: [
          { question: "How does James say we should view trials?", options: ["With anger and grief","As punishment from God","As pure joy, because testing produces perseverance","As something to avoid at all costs"], correct: 2, explanation: "James 1:2-3 says 'Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds, because you know that the testing of your faith produces perseverance.'" },
          { question: "What is the mirror analogy in James 1 about?", options: ["Vanity and pride","Hearing the Word without acting on it","The importance of prayer","Seeing God's image in yourself"], correct: 1, explanation: "James 1:23-24 says anyone who hears the word but does not do it is like someone who looks at their face in a mirror and immediately forgets what they look like." },
          { question: "What does James argue about faith without works?", options: ["It is still valid before God","It is for new believers","It is dead","It is better than works without faith"], correct: 2, explanation: "James 2:26 says 'As the body without the spirit is dead, so faith without deeds is dead.'" }
        ]
      },
      {
        id: "epistle-2",
        title: "1 Peter — Hope in Suffering",
        scripture: "1 Peter 1-5",
        teaching: "Peter writes to believers scattered across the Roman empire who were facing persecution. He reminds them they have a living hope through the resurrection of Jesus Christ — an inheritance that can never perish, spoil, or fade. Though they suffer various trials now, these have come to prove the genuineness of their faith. Peter urges them to humble themselves under God's mighty hand so He may lift them up in due time. He commands, 'Cast all your anxiety on him because he cares for you.' He warns that the devil prowls like a roaring lion, and believers must resist him, standing firm in the faith.",
        keyVerse: "Cast all your anxiety on him because he cares for you. — 1 Peter 5:7",
        questions: [
          { question: "What does Peter say believers have through the resurrection of Jesus?", options: ["Guaranteed wealth","Freedom from all suffering","A living hope and an imperishable inheritance","Leadership in the church"], correct: 2, explanation: "1 Peter 1:3-4 says 'God has given us new birth into a living hope through the resurrection of Jesus Christ from the dead, and into an inheritance that can never perish, spoil or fade.'" },
          { question: "What does Peter describe the devil as?", options: ["A snake in the grass","A prowling lion looking for someone to devour","A storm at sea","A fallen angel"], correct: 1, explanation: "1 Peter 5:8 says 'Your enemy the devil prowls around like a roaring lion looking for someone to devour.'" },
          { question: "What does Peter command believers to do with their anxieties?", options: ["Pray them away silently","Share them only with elders","Cast them on God because He cares for you","Ignore them and focus on others"], correct: 2, explanation: "1 Peter 5:7 says 'Cast all your anxiety on him because he cares for you.'" }
        ]
      },
      {
        id: "epistle-3",
        title: "1 John — Walking in the Light",
        scripture: "1 John 1-5",
        teaching: "John writes so that believers may have assurance of eternal life. God is light; in Him there is no darkness at all. If we claim to have fellowship with Him yet walk in darkness, we lie. But if we walk in the light, as He is in the light, we have fellowship with one another, and the blood of Jesus purifies us from all sin. John declares that God is love — whoever lives in love lives in God, and God in them. There is no fear in love; perfect love drives out fear. We love because He first loved us.",
        keyVerse: "God is love. Whoever lives in love lives in God, and God in them. — 1 John 4:16",
        questions: [
          { question: "What does John say God is, according to 1 John 1:5?", options: ["A consuming fire","All-knowing","Light; in him there is no darkness at all","An all-seeing eye"], correct: 2, explanation: "1 John 1:5 declares 'God is light; in him there is no darkness at all.'" },
          { question: "What does perfect love do according to 1 John 4:18?", options: ["Perfect love never fails","Perfect love drives out fear","Perfect love conquers sin","Perfect love builds community"], correct: 1, explanation: "1 John 4:18 says 'There is no fear in love. But perfect love drives out fear.'" },
          { question: "Why does John say we love God?", options: ["Because He commands it","Because we were raised that way","Because He first loved us","Because it brings us peace"], correct: 2, explanation: "1 John 4:19 says 'We love because he first loved us.'" }
        ]
      },
      {
        id: "epistle-4",
        title: "Hebrews — The Hall of Faith",
        scripture: "Hebrews 11-12",
        teaching: "The anonymous letter to the Hebrews defines faith as 'confidence in what we hope for and assurance about what we do not see.' Hebrews 11 then presents a sweeping gallery of Old Testament heroes — Abel, Enoch, Noah, Abraham, Sarah, Moses, Rahab, Gideon, David, and many others — who all lived and died by faith. None of them received what had been promised during their lifetimes, yet they did not waver. Therefore, since we are surrounded by such a great cloud of witnesses, we should throw off everything that hinders and the sin that so easily entangles, and run with perseverance the race marked out for us, fixing our eyes on Jesus.",
        keyVerse: "Let us run with perseverance the race marked out for us, fixing our eyes on Jesus, the pioneer and perfecter of faith. — Hebrews 12:1-2",
        questions: [
          { question: "How does Hebrews 11:1 define faith?", options: ["Belief without any evidence","Confidence in what we hope for and assurance about what we do not see","Blind obedience to God","A feeling of peace in hard times"], correct: 1, explanation: "Hebrews 11:1 defines faith as 'confidence in what we hope for and assurance about what we do not see.'" },
          { question: "What are believers described as being surrounded by in Hebrews 12:1?", options: ["Angels","A great cloud of witnesses","God's armor","The Holy Spirit"], correct: 1, explanation: "Hebrews 12:1 says 'Therefore, since we are surrounded by such a great cloud of witnesses' — referring to the heroes of faith in chapter 11." },
          { question: "On whom should we fix our eyes as we run the race?", options: ["The heroes of faith","The apostles","Jesus, the pioneer and perfecter of faith","The church community"], correct: 2, explanation: "Hebrews 12:2 says 'fixing our eyes on Jesus, the pioneer and perfecter of faith.'" }
        ]
      },
      {
        id: "epistle-5",
        title: "Revelation — The New Creation",
        scripture: "Revelation 1; 21-22",
        teaching: "The book of Revelation was given to the apostle John as a vision while exiled on the island of Patmos. Jesus appeared to John in brilliant glory — His face like the sun, His eyes like blazing fire, His voice like the sound of rushing waters. He dictated letters to seven churches. The vision climaxes with a new heaven and a new earth, for the first heaven and earth had passed away. God's dwelling place is now among the people, and He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain. Jesus declares, 'I am the Alpha and the Omega, the Beginning and the End.'",
        keyVerse: "He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain. — Revelation 21:4",
        questions: [
          { question: "Where was John when he received the Revelation?", options: ["Jerusalem","Rome","Antioch","The island of Patmos"], correct: 3, explanation: "Revelation 1:9 says 'I, John, your brother and companion in the suffering and kingdom and patient endurance that are ours in Jesus, was on the island of Patmos.'" },
          { question: "What does Revelation 21:4 promise about the new creation?", options: ["Streets of gold for all","No more death, mourning, crying, or pain","Eternal feasting","Restored bodies only"], correct: 1, explanation: "Revelation 21:4 says God 'will wipe every tear from their eyes. There will be no more death or mourning or crying or pain.'" },
          { question: "What does Jesus call Himself in Revelation?", options: ["The Lion of Judah only","The Good Shepherd","The Alpha and the Omega, the Beginning and the End","The Son of Man only"], correct: 2, explanation: "Revelation 22:13 says 'I am the Alpha and the Omega, the First and the Last, the Beginning and the End.'" }
        ]
      }
    ]
  }
];

export const TOPICS = [...BASE_TOPICS, ...EXTRA_TOPICS, ...EXTRA_TOPICS_2];

export const DAILY_VERSES = [
  { text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.", reference: "Jeremiah 29:11" },
  { text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.", reference: "Proverbs 3:5-6" },
  { text: "I can do all this through him who gives me strength.", reference: "Philippians 4:13" },
  { text: "The Lord is my light and my salvation—whom shall I fear? The Lord is the stronghold of my life—of whom shall I be afraid?", reference: "Psalm 27:1" },
  { text: "Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.", reference: "Joshua 1:9" },
  { text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.", reference: "Isaiah 40:31" },
  { text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.", reference: "Romans 8:28" },
  { text: "The Lord is close to the brokenhearted and saves those who are crushed in spirit.", reference: "Psalm 34:18" },
  { text: "Come to me, all you who are weary and burdened, and I will give you rest.", reference: "Matthew 11:28" },
  { text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.", reference: "Philippians 4:6" },
  { text: "He has shown you, O mortal, what is good. And what does the Lord require of you? To act justly and to love mercy and to walk humbly with your God.", reference: "Micah 6:8" },
  { text: "Your word is a lamp for my feet, a light on my path.", reference: "Psalm 119:105" },
  { text: "The name of the Lord is a fortified tower; the righteous run to it and are safe.", reference: "Proverbs 18:10" },
  { text: "But the fruit of the Spirit is love, joy, peace, patience, kindness, goodness, faithfulness, gentleness and self-control.", reference: "Galatians 5:22-23" },
  { text: "For we are God's handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.", reference: "Ephesians 2:10" },
  { text: "The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.", reference: "Zephaniah 3:17" },
  { text: "My grace is sufficient for you, for my power is made perfect in weakness.", reference: "2 Corinthians 12:9" },
  { text: "For it is by grace you have been saved, through faith — and this is not from yourselves, it is the gift of God.", reference: "Ephesians 2:8" },
  { text: "If we confess our sins, he is faithful and just and will forgive us our sins and purify us from all unrighteousness.", reference: "1 John 1:9" },
  { text: "Cast all your anxiety on him because he cares for you.", reference: "1 Peter 5:7" },
  { text: "Create in me a pure heart, O God, and renew a steadfast spirit within me.", reference: "Psalm 51:10" },
  { text: "I praise you because I am fearfully and wonderfully made.", reference: "Psalm 139:14" },
  { text: "God is our refuge and strength, an ever-present help in trouble.", reference: "Psalm 46:1" },
  { text: "Let us run with perseverance the race marked out for us, fixing our eyes on Jesus.", reference: "Hebrews 12:1-2" },
  { text: "Where you go I will go, and where you stay I will stay. Your people will be my people and your God my God.", reference: "Ruth 1:16" },
  { text: "He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain.", reference: "Revelation 21:4" },
  { text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.", reference: "John 3:16" },
  { text: "I am the way and the truth and the life. No one comes to the Father except through me.", reference: "John 14:6" }
];

export function getDailyVerse() {
  const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0)) / 86400000);
  return DAILY_VERSES[dayOfYear % DAILY_VERSES.length];
}

export function getLevelTitle(level) {
  if (level <= 2) return "Seeker";
  if (level <= 5) return "Disciple";
  if (level <= 10) return "Scholar";
  if (level <= 15) return "Teacher";
  if (level <= 20) return "Elder";
  return "Shepherd";
}

export function getXpForLevel(level) {
  return level * 100;
}