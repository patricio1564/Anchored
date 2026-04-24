// Additional lessons batch 2 — ~111 more lessons across new topics
export const EXTRA_TOPICS_2 = [
  // ─── THE TEN COMMANDMENTS DEEP DIVE ───────────────────────────────────────
  {
    id: "ten-commandments",
    title: "The Ten Commandments",
    description: "God's moral law explained",
    icon: "📋",
    color: "from-stone-500 to-amber-700",
    lessons: [
      {
        id: "tc-1",
        title: "No Other Gods Before Me",
        scripture: "Exodus 20:1-3; Deuteronomy 6:4-5",
        teaching: "The first commandment establishes the foundation for all the others: 'You shall have no other gods before me.' This is not merely about avoiding idol worship — it is a call to singular, whole-hearted devotion. Deuteronomy 6:4-5 captures it in the Shema: 'Hear, O Israel: The Lord our God, the Lord is one. Love the Lord your God with all your heart and with all your soul and with all your strength.' An 'other god' is anything we prioritize, fear, or trust more than the living God — money, comfort, approval, career. Jesus quoted the Shema as the greatest commandment.",
        keyVerse: "You shall have no other gods before me. — Exodus 20:3",
        questions: [
          { question: "What is the Shema in Deuteronomy 6:4?", options: ["A prayer for forgiveness","The declaration 'The Lord our God, the Lord is one'","A list of the ten commandments","A blessing for Israel"], correct: 1, explanation: "The Shema — 'Hear, O Israel: The Lord our God, the Lord is one' — is the central confession of Jewish faith and cited by Jesus as the greatest commandment." },
          { question: "According to Jesus, how are we to love God (from Deut. 6:5)?", options: ["With our words and offerings","With all our heart, soul, and strength","With obedience to the law alone","With silent reverence only"], correct: 1, explanation: "Deuteronomy 6:5 and Matthew 22:37 call us to love God 'with all your heart and with all your soul and with all your strength/mind.'" },
          { question: "What can be a 'god' in modern life?", options: ["Only statues and idols","Only foreign religions","Anything we prioritize or trust more than God — money, approval, comfort","Nothing in modern life qualifies"], correct: 2, explanation: "The first commandment is about ultimate allegiance. Anything that takes God's place in our hearts — money, career, relationships — functions as an idol." }
        ]
      },
      {
        id: "tc-2",
        title: "No Idols — God Cannot Be Contained",
        scripture: "Exodus 20:4-6; Isaiah 44:9-20",
        teaching: "The second commandment forbids making carved images to worship. Isaiah 44 shows the absurdity of idol worship — a man cuts down a tree, burns half to warm himself and cook food, then makes a god from the other half and bows down to it. God alone is the living God; He cannot be reduced to a human creation. But this commandment is not only about statues — it also warns against creating a god 'in our own image,' mentally shaping God into who we want Him to be rather than who He has revealed Himself to be. God is holy, other, and cannot be domesticated.",
        keyVerse: "You shall not make for yourself an image in the form of anything in heaven above or on the earth beneath. — Exodus 20:4",
        questions: [
          { question: "What does Isaiah 44 highlight about physical idol worship?", options: ["It was common but not sinful","The same wood used to make a god is also used for fuel — showing its absurdity","Idols were once permitted but later banned","Idol worship was only wrong in Egypt"], correct: 1, explanation: "Isaiah 44:16-17 exposes the absurdity: the man burns half the wood for warmth and says of the other half 'Be my god!'" },
          { question: "What is a modern form of breaking this commandment?", options: ["Taking selfies","Reading non-Christian books","Mentally shaping God to be who we want rather than who He has revealed Himself to be","Going to museums with statues"], correct: 2, explanation: "Creating a god 'in our image' by rejecting aspects of God's revealed character — His holiness, judgment, or exclusivity — is a form of idolatry." },
          { question: "What does God say about Himself in Exodus 20:5?", options: ["He is a forgiving God who overlooks all sin","He is a jealous God — committed to His people's exclusive devotion","He is distant and uninvolved","He shares worship with other beings"], correct: 1, explanation: "Exodus 20:5 says 'I, the Lord your God, am a jealous God' — meaning He is zealous for His people's exclusive devotion, like a faithful spouse." }
        ]
      },
      {
        id: "tc-3",
        title: "The Sabbath — Rest as Worship",
        scripture: "Exodus 20:8-11; Mark 2:27-28",
        teaching: "The fourth commandment says: 'Remember the Sabbath day by keeping it holy. Six days you shall labor and do all your work, but the seventh day is a sabbath to the Lord your God.' God modeled rest on the seventh day of creation — not because He was tired but to establish a pattern for humanity. The Sabbath declares that we are not defined by our productivity. Jesus said 'The Sabbath was made for man, not man for the Sabbath' — it is a gift of rest, not a burdensome rule. Christians often observe the spirit of Sabbath on Sunday, the day of resurrection.",
        keyVerse: "The Sabbath was made for man, not man for the Sabbath. — Mark 2:27",
        questions: [
          { question: "What is the basis for the Sabbath commandment given in Exodus 20?", options: ["Israel's slavery in Egypt","The need for economic productivity","God rested on the seventh day of creation","The Jewish calendar system"], correct: 2, explanation: "Exodus 20:11 says 'For in six days the Lord made the heavens and the earth... but he rested on the seventh day. Therefore the Lord blessed the Sabbath day and made it holy.'" },
          { question: "What does the Sabbath fundamentally declare about humanity?", options: ["We are stronger than we think","We are not defined by our productivity — rest is holy","Work is the highest calling","We should always remain still"], correct: 1, explanation: "The Sabbath declares our identity is in God, not our work. We are human beings, not human doings." },
          { question: "What did Jesus say about the Sabbath in Mark 2:27?", options: ["The Sabbath is no longer required","The Sabbath was made for man, not man for the Sabbath","The Sabbath must be observed strictly","Only priests may observe the Sabbath"], correct: 1, explanation: "Mark 2:27 — 'The Sabbath was made for man, not man for the Sabbath.' Jesus emphasized the Sabbath as a gift for human flourishing." }
        ]
      },
      {
        id: "tc-4",
        title: "Honor Your Father and Mother",
        scripture: "Exodus 20:12; Ephesians 6:1-4",
        teaching: "The fifth commandment — 'Honor your father and your mother' — is the first commandment with a promise: 'so that you may live long in the land the Lord your God is giving you.' It bridges the God-centered commandments and the people-centered ones. Honoring parents teaches us submission to legitimate authority, which shapes character and society. Paul in Ephesians says children should obey their parents 'in the Lord, for this is right.' However, he immediately adds: 'Fathers, do not exasperate your children; instead, bring them up in the training and instruction of the Lord' — the obligation runs both ways.",
        keyVerse: "Honor your father and your mother, so that you may live long in the land the Lord your God is giving you. — Exodus 20:12",
        questions: [
          { question: "What makes the fifth commandment unique among the Ten?", options: ["It's the longest commandment","It's the only one about family","It's the first commandment with a promise attached","It was added later by Moses"], correct: 2, explanation: "Ephesians 6:2-3 notes it is 'the first commandment with a promise' — long life in the land." },
          { question: "What does Paul add for fathers in Ephesians 6:4?", options: ["Fathers should be strict above all else","Fathers must not exasperate their children but bring them up in God's instruction","Fathers are exempt from the commandment","Fathers should delegate parenting to mothers"], correct: 1, explanation: "Ephesians 6:4 says 'Fathers, do not exasperate your children; instead, bring them up in the training and instruction of the Lord.'" },
          { question: "What broader principle does honoring parents teach?", options: ["That parents are always right","Submission to God-given authority, shaping character and society","That children have no rights","That family is more important than God"], correct: 1, explanation: "Honoring parents teaches respect for legitimate authority — a foundational value for healthy communities and character formation." }
        ]
      },
      {
        id: "tc-5",
        title: "You Shall Not Murder",
        scripture: "Exodus 20:13; Matthew 5:21-22",
        teaching: "The sixth commandment forbids murder — the unjust taking of human life. The basis is the image of God: every human life is sacred because every person bears the imago Dei. But Jesus deepened this commandment: 'You have heard it said, Do not murder. But I tell you that anyone who is angry with a brother or sister will be subject to judgment.' Jesus targeted the heart behind murder — unrighteous anger, contempt, and hatred. Calling someone a fool puts you in danger of hell. This is not about human justice systems but about the radical standard of God's kingdom, where hatred is the seed of murder.",
        keyVerse: "You shall not murder. — Exodus 20:13",
        questions: [
          { question: "Why is human life sacred according to Genesis?", options: ["Because governments have made laws protecting it","Because humans are the most intelligent creatures","Every person bears the image of God — imago Dei","Because life is scarce and valuable"], correct: 2, explanation: "Genesis 9:6 grounds the prohibition against murder in the image of God: 'Whoever sheds human blood, by humans shall their blood be shed; for in the image of God has God made mankind.'" },
          { question: "How did Jesus expand the sixth commandment in Matthew 5?", options: ["He said it no longer applied under grace","He added that self-defense is permitted","He said anger and contempt toward others also violate the spirit of this law","He restricted it to premeditated murder only"], correct: 2, explanation: "Matthew 5:21-22 shows Jesus reaching to the heart: 'anyone who is angry with a brother or sister will be subject to judgment.'" },
          { question: "What does Jesus say about calling someone a fool?", options: ["It is permitted in debate","It is sinful but minor","It puts you in danger of the fire of hell","It only matters if you mean it"], correct: 2, explanation: "Matthew 5:22 says 'anyone who says, You fool! will be in danger of the fire of hell' — revealing how seriously God regards contempt for others." }
        ]
      },
      {
        id: "tc-6",
        title: "You Shall Not Steal — Respecting Others",
        scripture: "Exodus 20:15; Ephesians 4:28",
        teaching: "The eighth commandment forbids stealing. This includes obvious theft but also tax evasion, dishonest business practices, copyright infringement, and failing to pay fair wages. Paul in Ephesians 4:28 turns this from mere prohibition to positive command: 'Anyone who has been stealing must steal no longer, but must work, doing something useful with their own hands, that they may have something to share with those in need.' The goal is not just stopping theft but becoming someone who gives generously. The transformed thief becomes a generous giver — the same hands that once took now extend in generosity.",
        keyVerse: "Anyone who has been stealing must steal no longer, but must work... that they may have something to share with those in need. — Ephesians 4:28",
        questions: [
          { question: "What forms of stealing does the eighth commandment cover beyond obvious theft?", options: ["Only physical theft of property","Dishonest business practices, unpaid wages, and exploitation also fall under this law","It only covers money, not property","It only applied to ancient Israel"], correct: 1, explanation: "The commandment's principle covers any unjust taking — dishonest scales (Proverbs 11:1), withholding wages (James 5:4), and fraudulent practices." },
          { question: "What does Paul say the reformed thief should do?", options: ["Repay double what was stolen","Never touch money again","Work honestly and share with those in need","Become a priest or church worker"], correct: 2, explanation: "Ephesians 4:28 says the former thief should 'work, doing something useful with their own hands, that they may have something to share with those in need.'" },
          { question: "What transformation does Paul envision in Ephesians 4:28?", options: ["From poor to wealthy","From criminal to law-abiding","From one who takes to one who gives generously","From lazy to hard-working only"], correct: 2, explanation: "The same hands that once took now give — the deepest transformation is from a taker to a giver, reflecting the character of God." }
        ]
      }
    ]
  },

  // ─── THE SERMON ON THE MOUNT DEEP DIVE ────────────────────────────────────
  {
    id: "sermon-mount",
    title: "Sermon on the Mount",
    description: "The radical ethics of God's kingdom",
    icon: "⛰️",
    color: "from-blue-500 to-indigo-600",
    lessons: [
      {
        id: "som-1",
        title: "Blessed Are the Mourners and Meek",
        scripture: "Matthew 5:4-5",
        teaching: "Jesus declares: 'Blessed are those who mourn, for they will be comforted.' This mourning is not merely grief at personal loss but sorrow over sin — both one's own sin and the brokenness of the world. Those who weep over the distance between God's kingdom and present reality will be comforted by His presence and ultimate renewal. 'Blessed are the meek, for they will inherit the earth' — meekness is not weakness but power under control. Moses was called the most meek man on earth (Numbers 12:3) yet led two million people. Meekness is strength submitted to God.",
        keyVerse: "Blessed are the meek, for they will inherit the earth. — Matthew 5:5",
        questions: [
          { question: "What kind of mourning does Jesus bless in Matthew 5:4?", options: ["Only mourning at funerals","Mourning over personal failures only","Sorrow over sin and the brokenness of the world","Mourning that produces depression"], correct: 2, explanation: "The mourning Jesus blesses is associated with contrition over sin and grief over evil in the world — it produces a longing for God's kingdom." },
          { question: "What does meekness actually mean?", options: ["Being shy and quiet","Having no opinions","Power under control — strength submitted to God","Allowing others to abuse you"], correct: 2, explanation: "Meekness (Greek: praus) was used of a powerful horse trained to obey — it is controlled strength, not weakness." },
          { question: "Who in the Old Testament was called the most meek man on earth?", options: ["David","Abraham","Elijah","Moses"], correct: 3, explanation: "Numbers 12:3 says 'Now Moses was a very humble man, more humble than anyone else on the face of the earth' — yet he led Israel powerfully." }
        ]
      },
      {
        id: "som-2",
        title: "Anger, Lust, and Integrity",
        scripture: "Matthew 5:21-30",
        teaching: "Jesus tackles the heart behind the law. On anger: reconcile with your brother before bringing your offering to the altar — relationships matter more than religious ritual. On lust: 'Anyone who looks at a woman lustfully has already committed adultery with her in his heart.' Jesus uses dramatic hyperbole — 'gouge out your eye' — to show how seriously we must take the battle for purity. He is not calling for physical self-harm but saying no sacrifice is too great to protect the purity of the heart. The kingdom of God requires radical internal transformation, not just external compliance.",
        keyVerse: "Anyone who looks at a woman lustfully has already committed adultery with her in his heart. — Matthew 5:28",
        questions: [
          { question: "What does Jesus say should happen before bringing an offering if you have a conflict?", options: ["Bring the offering first, then reconcile","Offer the gift and pray for reconciliation","Leave the gift and first be reconciled with your brother","Ask a priest to mediate"], correct: 2, explanation: "Matthew 5:23-24 says 'leave your gift there in front of the altar. First go and be reconciled to them; then come and offer your gift.'" },
          { question: "What does Jesus mean by 'gouge out your eye' in Matthew 5:29?", options: ["Literal self-surgery","That physical blindness is holy","Dramatic hyperbole — no sacrifice is too great for the battle for purity","A command about medical procedures"], correct: 2, explanation: "Jesus uses hyperbole to show radical seriousness about heart purity — He is not commanding self-mutilation." },
          { question: "Where does Jesus locate the real battle for morality?", options: ["In the laws of society","In church attendance","In the heart — not just external behavior","In religious rituals"], correct: 2, explanation: "Matthew 5:21-30 consistently moves from external action to internal motivation — the heart is where moral transformation begins." }
        ]
      },
      {
        id: "som-3",
        title: "Fasting, Treasure, and Judging",
        scripture: "Matthew 6:16-7:5",
        teaching: "Jesus continues the Sermon. On fasting: do not look somber like hypocrites who show their fasting publicly. Instead wash your face and comb your hair — let only the Father see. On judging: 'Do not judge, or you too will be judged. For in the same way you judge others, you will be judged.' The famous speck-and-plank metaphor: before removing the speck from someone else's eye, remove the plank from your own. This does not mean never discern right from wrong — it means deal with your own sin before correcting others. Humility must precede correction.",
        keyVerse: "Do not judge, or you too will be judged. — Matthew 7:1",
        questions: [
          { question: "How does Jesus say we should fast?", options: ["Publicly for accountability","With somber faces to show seriousness","Washed and groomed so only the Father sees, not people","With other believers together only"], correct: 2, explanation: "Matthew 6:17-18 says 'when you fast, put oil on your head and wash your face, so that it will not be obvious to others that you are fasting, but only to your Father.'" },
          { question: "What does the speck-and-plank metaphor teach?", options: ["Never correct anyone ever","Good eyesight is a spiritual gift","Deal with your own sin humbly before correcting others","Small sins are more dangerous than large ones"], correct: 2, explanation: "Matthew 7:3-5 — remove the plank from your own eye first, then you will see clearly to remove the speck from your brother's eye." },
          { question: "Does 'do not judge' mean never discern right from wrong?", options: ["Yes — Christians must never make moral judgments","No — it means avoid hypocritical condemnation while ignoring your own sin","Yes — only God can ever judge anything","It means defer all judgments to church leaders"], correct: 1, explanation: "Matthew 7:1-5 targets hypocritical judgment — condemning others while ignoring greater sin in yourself — not the elimination of all moral discernment." }
        ]
      },
      {
        id: "som-4",
        title: "Ask, Seek, Knock",
        scripture: "Matthew 7:7-12",
        teaching: "Jesus gives one of the most expansive promises about prayer: 'Ask and it will be given to you; seek and you will find; knock and the door will be opened to you.' The verbs are in continuous tense — keep asking, keep seeking, keep knocking. He draws on the father-child relationship: what earthly father gives his child a stone when he asks for bread? How much more will your heavenly Father give good gifts to those who ask? The parallel passage in Luke 11:13 says the greatest gift is the Holy Spirit. The Golden Rule follows: 'Do to others what you would have them do to you, for this sums up the Law and the Prophets.'",
        keyVerse: "Ask and it will be given to you; seek and you will find; knock and the door will be opened to you. — Matthew 7:7",
        questions: [
          { question: "What tense are the verbs 'ask, seek, knock' in the original Greek?", options: ["Past tense","Future tense","Continuous — keep asking, keep seeking, keep knocking","They are commands for a single action"], correct: 2, explanation: "The Greek present imperative indicates ongoing, persistent action: keep asking, keep seeking, keep knocking." },
          { question: "What does Luke 11:13 say is the greatest gift the Father gives to those who ask?", options: ["Wealth and health","Answered prayers generally","The Holy Spirit","Wisdom and understanding"], correct: 2, explanation: "Luke 11:13 says 'how much more will your Father in heaven give the Holy Spirit to those who ask him!'" },
          { question: "What does Jesus say the Golden Rule summarizes?", options: ["The Ten Commandments","The Beatitudes","The Law and the Prophets","The greatest commandment only"], correct: 2, explanation: "Matthew 7:12 says 'So in everything, do to others what you would have them do to you, for this sums up the Law and the Prophets.'" }
        ]
      },
      {
        id: "som-5",
        title: "The Wise and Foolish Builders",
        scripture: "Matthew 7:24-29",
        teaching: "Jesus closes the Sermon on the Mount with a vivid parable. Everyone who hears His words and puts them into practice is like a wise man who built his house on the rock — when rain fell, streams rose, and winds blew, the house stood firm because it was founded on rock. But everyone who hears His words and does not put them into practice is like a foolish man who built on sand — when the storm came, the house fell with a great crash. The key word is 'practice' — not hearing, agreeing, or admiring, but doing. The crowds were amazed because Jesus taught as one who had authority.",
        keyVerse: "Everyone who hears these words of mine and puts them into practice is like a wise man who built his house on the rock. — Matthew 7:24",
        questions: [
          { question: "What is the difference between the wise and foolish builder?", options: ["The wise builder used better materials","The wise builder hears AND practices Jesus' words; the foolish only hears","The wise builder chose a better location","The wise builder had more money and resources"], correct: 1, explanation: "Matthew 7:24-26 shows the only difference is action: 'hears these words of mine and puts them into practice' versus hears but does not put into practice." },
          { question: "What happened to the house built on sand?", options: ["It survived with minor damage","It needed repairs but stood","It gradually sank into the ground","It fell with a great crash"], correct: 3, explanation: "Matthew 7:27 says 'it fell with a great crash' — representing the catastrophic collapse of a life not built on obedience to Christ." },
          { question: "Why were the crowds amazed at the end of the Sermon?", options: ["Because of the miracles He performed","Because the sermon was so long","Because Jesus taught as one who had authority, not as their teachers of the law","Because many people were healed"], correct: 2, explanation: "Matthew 7:28-29 says 'the crowds were amazed at his teaching, because he taught as one who had authority, and not as their teachers of the law.'" }
        ]
      }
    ]
  },

  // ─── JOHN'S GOSPEL — I AM STATEMENTS ──────────────────────────────────────
  {
    id: "i-am-statements",
    title: "The 'I Am' Statements of Jesus",
    description: "Seven divine declarations in John",
    icon: "🕯️",
    color: "from-amber-400 to-yellow-500",
    lessons: [
      {
        id: "iam-1",
        title: "I Am the Bread of Life",
        scripture: "John 6:22-59",
        teaching: "After feeding five thousand people, a crowd chased Jesus looking for more bread. He redirected them: 'Do not work for food that spoils, but for food that endures to eternal life.' They asked what miraculous sign He would give — noting that Moses gave manna in the desert. Jesus corrected them: Moses did not give them the bread from heaven — the Father gives the true bread from heaven. 'I am the bread of life. Whoever comes to me will never go hungry, and whoever believes in me will never be thirsty.' Just as physical bread sustains the body, Jesus sustains the soul with eternal life.",
        keyVerse: "I am the bread of life. Whoever comes to me will never go hungry, and whoever believes in me will never be thirsty. — John 6:35",
        questions: [
          { question: "Why did the crowd follow Jesus to Capernaum?", options: ["They wanted to hear more teaching","They wanted to make Him king","They wanted more bread after He fed the five thousand","They were His regular disciples"], correct: 2, explanation: "John 6:26 says Jesus told them 'you are looking for me, not because you saw the signs I performed but because you ate the loaves and had your fill.'" },
          { question: "Who does Jesus say actually gave the manna in the desert?", options: ["Moses gave the manna","The angels distributed it","The Father — not Moses — gave the true bread from heaven","God gave it through Moses' prayer"], correct: 2, explanation: "John 6:32 says 'It is not Moses who has given you the bread from heaven, but it is my Father who gives you the true bread from heaven.'" },
          { question: "What does the 'bread of life' provide that physical bread cannot?", options: ["Physical strength and health","Eternal life — those who come to Jesus will never hunger or thirst again","Better mental clarity","Longer physical life"], correct: 1, explanation: "John 6:35 — 'Whoever comes to me will never go hungry, and whoever believes in me will never be thirsty' — Jesus satisfies the deepest spiritual hunger." }
        ]
      },
      {
        id: "iam-2",
        title: "I Am the Light of the World",
        scripture: "John 8:12; 9:5",
        teaching: "At the Feast of Tabernacles, Jesus declared: 'I am the light of the world. Whoever follows me will never walk in darkness, but will have the light of life.' This was spoken in the temple treasury near the massive lampstands lit during the festival — a powerful visual context. The Pharisees objected that His testimony was invalid because He testified about Himself. Jesus said His testimony was valid because He knew where He came from. He also said 'While I am in the world, I am the light of the world' just before healing the blind man — demonstrating His claim through miraculous sight.",
        keyVerse: "I am the light of the world. Whoever follows me will never walk in darkness, but will have the light of life. — John 8:12",
        questions: [
          { question: "During what Jewish festival did Jesus declare 'I am the light of the world'?", options: ["Passover","Pentecost","The Feast of Tabernacles","The Day of Atonement"], correct: 2, explanation: "John 7-8 places this declaration during the Feast of Tabernacles, when massive lampstands were lit in the temple — making the claim especially vivid." },
          { question: "What promise comes with following the Light of the World?", options: ["Physical prosperity and long life","Perfect wisdom and knowledge","Never walking in darkness — having the light of life","Freedom from all suffering"], correct: 2, explanation: "John 8:12 says 'Whoever follows me will never walk in darkness, but will have the light of life.'" },
          { question: "How did Jesus demonstrate this claim practically?", options: ["By lighting lamps in the temple","By healing a blind man — giving literal sight to illustrate spiritual light","By transfiguring on the mountain","By rising from the dead"], correct: 1, explanation: "John 9 immediately follows with the healing of the blind man — 'I am the light of the world' (9:5) followed by restoring physical sight as a sign." }
        ]
      },
      {
        id: "iam-3",
        title: "I Am the Good Shepherd",
        scripture: "John 10:1-18",
        teaching: "Jesus contrasts Himself with thieves and hirelings. Thieves come to steal, kill, and destroy — He came that people may have life to the full. The hireling abandons the sheep when danger comes, but the Good Shepherd lays down His life for the sheep. He knows His sheep by name; they recognize His voice and follow Him. He has other sheep not from this fold — Gentiles — and they too will listen to His voice; there will be one flock and one shepherd. This is a deeply personal portrait of Jesus' relationship with believers — intimate, protective, sacrificial.",
        keyVerse: "I am the good shepherd. The good shepherd lays down his life for the sheep. — John 10:11",
        questions: [
          { question: "What does Jesus say the thief comes to do?", options: ["Test the shepherd","Steal, kill, and destroy","Challenge God's authority","Scatter the flock only"], correct: 1, explanation: "John 10:10 — 'The thief comes only to steal and kill and destroy; I have come that they may have life, and have it to the full.'" },
          { question: "What does the hireling do when danger comes?", options: ["Fights for the sheep","Calls for help","Abandons the sheep and runs — because he doesn't own them","Leads the sheep to safety first"], correct: 2, explanation: "John 10:12-13 says the hired hand 'abandons the sheep and runs away' because he is not the shepherd and doesn't care for the sheep." },
          { question: "What does Jesus say about 'other sheep' in John 10:16?", options: ["He will form separate flocks for different nations","They are lost forever","Other sheep not of this fold will hear His voice; there will be one flock and one shepherd","Only Jewish believers are His sheep"], correct: 2, explanation: "John 10:16 — 'I have other sheep that are not of this sheep pen... there shall be one flock and one shepherd' — pointing to Gentile believers." }
        ]
      },
      {
        id: "iam-4",
        title: "I Am the Resurrection and the Life",
        scripture: "John 11:17-27",
        teaching: "When Jesus arrived in Bethany four days after Lazarus died, Martha met Him on the road and said 'Lord, if you had been here, my brother would not have died.' Jesus told her Lazarus would rise again. Martha assumed He meant the final resurrection. Jesus corrected her with an extraordinary present-tense claim: 'I AM the resurrection and the life. The one who believes in me will live, even though they die; and whoever lives by believing in me will never die.' Before raising Lazarus, He claimed to be the source of resurrection itself — not merely someone who could perform resurrections.",
        keyVerse: "I am the resurrection and the life. The one who believes in me will live, even though they die. — John 11:25",
        questions: [
          { question: "What was Martha's initial assumption about Lazarus rising again?", options: ["Jesus would raise him immediately","He would rise at the final resurrection someday","He was not really dead","She had no hope of resurrection"], correct: 1, explanation: "John 11:24 — Martha said 'I know he will rise again in the resurrection at the last day.' She was thinking of a future event." },
          { question: "What was remarkable about Jesus' claim 'I AM the resurrection'?", options: ["He used the divine name I AM","He claimed to be the source of resurrection itself, not just someone who performs them","He predicted His own resurrection","He used present tense in Aramaic"], correct: 1, explanation: "Jesus didn't say 'I will cause a resurrection' but 'I AM the resurrection and the life' — claiming to personally embody resurrection power." },
          { question: "What question did Jesus ask Martha to test her faith?", options: ["Do you love me more than these?","Do you believe in the final resurrection?","Do you believe this?","Will you trust me even now?"], correct: 2, explanation: "John 11:26 records Jesus asking 'Do you believe this?' — calling for personal trust in His resurrection claim." }
        ]
      },
      {
        id: "iam-5",
        title: "I Am the True Vine",
        scripture: "John 15:1-17",
        teaching: "On the night of His arrest, Jesus declared 'I am the true vine, and my Father is the gardener.' Every branch that bears fruit He prunes so it bears more fruit. 'Remain in me, as I also remain in you. No branch can bear fruit by itself; it must remain in the vine. Neither can you bear fruit unless you remain in me.' Apart from Jesus, His followers can do nothing. But those who remain in Him bear much fruit and glorify the Father. He commands them to love each other as He loved them — laying down His life. This is both the fruit and the evidence of remaining in the vine.",
        keyVerse: "I am the vine; you are the branches. If you remain in me and I in you, you will bear much fruit; apart from me you can do nothing. — John 15:5",
        questions: [
          { question: "What does the Father (the gardener) do to branches that bear fruit?", options: ["Leaves them untouched","Removes them from the vine","Prunes them so they bear even more fruit","Moves them to better soil"], correct: 2, explanation: "John 15:2 says 'every branch that does bear fruit he prunes so that it will be even more fruitful.'" },
          { question: "What does Jesus say happens apart from Him?", options: ["Believers grow slowly","Fruit is harder to produce","You can do nothing — no spiritual fruit apart from Christ","Good works can still be done"], correct: 2, explanation: "John 15:5 says 'apart from me you can do nothing' — all spiritual productivity flows from abiding connection to Christ." },
          { question: "What does Jesus call the evidence of being His disciples?", options: ["Speaking in tongues","Performing miracles","Bearing much fruit","Having perfect theology"], correct: 2, explanation: "John 15:8 says 'This is to my Father's glory, that you bear much fruit, showing yourselves to be my disciples.'" }
        ]
      }
    ]
  },

  // ─── ANGELS AND SPIRITUAL WARFARE ─────────────────────────────────────────
  {
    id: "spiritual-world",
    title: "Angels & Spiritual Warfare",
    description: "The unseen spiritual realm",
    icon: "⚔️",
    color: "from-slate-400 to-blue-600",
    lessons: [
      {
        id: "sw-1",
        title: "The Angel Gabriel",
        scripture: "Luke 1:8-20; 26-38; Daniel 9:21",
        teaching: "Gabriel is one of two named angels in Scripture (the other is Michael). He appears to Daniel to explain prophetic visions and is described as coming in swift flight. In Luke 1, Gabriel appears to Zechariah in the temple to announce the birth of John the Baptist — Zechariah doubted and was struck mute until the birth. Gabriel then appeared to Mary to announce the incarnation of Jesus. Angels in Scripture are always created beings who serve as God's messengers — they never invite worship. When the apostle John fell at an angel's feet, the angel said 'Don't do that! I am a fellow servant. Worship God!'",
        keyVerse: "The angel answered, 'I am Gabriel. I stand in the presence of God, and I have been sent to speak to you.' — Luke 1:19",
        questions: [
          { question: "What happened to Zechariah when he doubted Gabriel's announcement?", options: ["He was blinded","He was struck mute until John was born","He was sent out of the temple","He immediately believed"], correct: 1, explanation: "Luke 1:20 says Zechariah would be silent and unable to speak until the day of fulfillment 'because you did not believe my words.'" },
          { question: "How does Gabriel describe himself to Zechariah?", options: ["A servant of Israel","The highest angel in heaven","I stand in the presence of God — I have been sent to speak to you","A created being below humans"], correct: 2, explanation: "Luke 1:19 — Gabriel identifies himself as one who 'stand[s] in the presence of God' — a messenger dispatched from the divine throne room." },
          { question: "What should we NOT do toward angels, according to Revelation 22:8-9?", options: ["Pray to them","Worship them — the angel says 'I am a fellow servant; worship God!'","Ask them for help","Think about them"], correct: 1, explanation: "Revelation 22:8-9 records an angel saying 'Don't do that! I am a fellow servant with you... Worship God!'" }
        ]
      },
      {
        id: "sw-2",
        title: "The Whole Armor of God",
        scripture: "Ephesians 6:10-18",
        teaching: "Paul urges believers to put on the full armor of God because our struggle is not against flesh and blood but against rulers, authorities, powers of this dark world, and spiritual forces of evil in the heavenly realms. The armor: Belt of Truth — truthful character as the foundation. Breastplate of Righteousness — moral integrity protecting the heart. Gospel of Peace on the feet — readiness to share the Good News. Shield of Faith — extinguishing the flaming arrows of accusation and temptation. Helmet of Salvation — protecting the mind with the assurance of salvation. Sword of the Spirit — the Word of God, the only offensive weapon. And pray at all times.",
        keyVerse: "Put on the full armor of God, so that you can take your stand against the devil's schemes. — Ephesians 6:11",
        questions: [
          { question: "What does the belt of truth refer to?", options: ["Reading the Bible regularly","Truthful, integrated character as the foundation of spiritual stability","Memorizing Scripture accurately","Wearing a prayer shawl"], correct: 1, explanation: "The belt in Roman armor held everything together. Truth — living with integrity and honesty — is the foundational element of spiritual armor." },
          { question: "What is the only offensive weapon in the armor of God?", options: ["The shield of faith","The breastplate of righteousness","The sword of the Spirit — the Word of God","The helmet of salvation"], correct: 2, explanation: "Ephesians 6:17 identifies the sword of the Spirit as the Word of God — used both to resist the enemy (as Jesus did in temptation) and to proclaim truth." },
          { question: "What does the gospel of peace on the feet represent?", options: ["Running away from conflict","Readiness to bring and share the Good News wherever we go","Perfect inner peace","Peace with the Roman empire"], correct: 1, explanation: "Feet fitted with the gospel of peace represents readiness and mobility — being prepared to carry and share the message of peace." }
        ]
      },
      {
        id: "sw-3",
        title: "Michael the Archangel",
        scripture: "Daniel 10:12-21; Jude 1:9; Revelation 12:7-9",
        teaching: "Michael is named as an archangel — the only being in Scripture explicitly called by this title. In Daniel 10, a heavenly messenger tells Daniel that Michael helped fight a spiritual prince of Persia in a cosmic battle. In Jude 1:9, Michael disputes with the devil over the body of Moses and says 'The Lord rebuke you!' — even the archangel appeals to God's authority rather than fighting in his own strength. In Revelation 12, Michael and his angels fight against the dragon (Satan) and his angels, and the dragon is hurled to the earth. Angels operate in an unseen war affecting earthly events.",
        keyVerse: "But even the archangel Michael... said, 'The Lord rebuke you!' — Jude 1:9",
        questions: [
          { question: "In Daniel 10, what was Michael doing while the messenger was delayed?", options: ["Delivering another message","Fighting the prince of Persia — a spiritual battle affecting earthly kingdoms","Worshiping before God's throne","Protecting Daniel directly"], correct: 1, explanation: "Daniel 10:13 reveals that 'the prince of the Persian kingdom resisted me twenty-one days. Then Michael, one of the chief princes, came to help me.'" },
          { question: "What does Michael say to the devil in Jude 1:9?", options: ["I am stronger than you","The Lord rebuke you!","You have no authority here","Depart from me"], correct: 1, explanation: "Jude 1:9 records Michael saying 'The Lord rebuke you!' — showing that even the archangel relies on God's authority, not his own." },
          { question: "What does Revelation 12 describe Michael doing?", options: ["Delivering a message to John","Standing guard over Israel","Fighting the dragon (Satan) and casting him and his angels to earth","Opening the seven seals"], correct: 2, explanation: "Revelation 12:7-9 describes war in heaven: 'Michael and his angels fought against the dragon... The great dragon was hurled down—that ancient serpent called the devil.'" }
        ]
      },
      {
        id: "sw-4",
        title: "Resist the Devil — James 4",
        scripture: "James 4:7-10; 1 Peter 5:8-9",
        teaching: "James gives the most direct command about spiritual resistance: 'Submit yourselves, then, to God. Resist the devil, and he will flee from you. Come near to God and he will come near to you.' The order matters: first submit to God, then resist the devil. Spiritual warfare begins with surrender to God, not aggressive battle techniques. Peter adds: 'Your enemy the devil prowls around like a roaring lion looking for someone to devour. Resist him, standing firm in the faith.' Both apostles ground resistance in faith and closeness to God, not in dramatic spiritual techniques.",
        keyVerse: "Submit yourselves, then, to God. Resist the devil, and he will flee from you. — James 4:7",
        questions: [
          { question: "What must come BEFORE resisting the devil, according to James 4:7?", options: ["Fasting and prayer","Rebuking the devil loudly","Submitting to God","Finding a prayer partner"], correct: 2, explanation: "James 4:7 — 'Submit yourselves, then, to God. Resist the devil.' Submission to God comes first and is the foundation for effective resistance." },
          { question: "What happens when we resist the devil?", options: ["He attacks more fiercely","He does not affect believers","He will flee from you","He changes tactics"], correct: 2, explanation: "James 4:7 promises 'Resist the devil, and he will flee from you' — resistance through God's authority makes the enemy retreat." },
          { question: "How does Peter describe the devil?", options: ["A fallen star in the sky","A powerful storm at sea","A prowling lion looking for someone to devour","A whispering voice of temptation"], correct: 2, explanation: "1 Peter 5:8 — 'Your enemy the devil prowls around like a roaring lion looking for someone to devour.'" }
        ]
      }
    ]
  },

  // ─── THE LORD'S SUPPER AND BAPTISM ────────────────────────────────────────
  {
    id: "sacraments",
    title: "Baptism & Communion",
    description: "Ordinances given by Jesus",
    icon: "🥖",
    color: "from-red-400 to-rose-600",
    lessons: [
      {
        id: "sac-1",
        title: "The Meaning of Baptism",
        scripture: "Romans 6:1-11; Matthew 28:19",
        teaching: "Baptism is an outward sign of an inward transformation. Paul explains that being baptized into Christ Jesus means being baptized into His death — buried with Him through baptism into death, so that just as Christ was raised, we too may live a new life. It declares: the old self is dead, a new self is alive. Jesus commanded baptism as part of the Great Commission: 'baptizing them in the name of the Father and of the Son and of the Holy Spirit.' Baptism does not save — only faith in Christ saves — but it publicly declares and seals the believer's union with Christ.",
        keyVerse: "We were therefore buried with him through baptism into death in order that, just as Christ was raised from the dead... we too may live a new life. — Romans 6:4",
        questions: [
          { question: "What does Paul say baptism symbolizes?", options: ["Washing away physical sin","Being buried with Christ in His death and raised to new life","Joining a religious community","Receiving the Holy Spirit"], correct: 1, explanation: "Romans 6:3-4 explains baptism as a symbol of dying to the old self (buried with Christ) and rising to new life (raised with Christ)." },
          { question: "In whose name does Jesus say we should baptize?", options: ["Jesus' name only","The Father's name only","The Holy Spirit's name only","The name of the Father, Son, and Holy Spirit"], correct: 3, explanation: "Matthew 28:19 says 'baptizing them in the name of the Father and of the Son and of the Holy Spirit.'" },
          { question: "What does baptism declare about the believer?", options: ["That they are now sinless","That they have joined a specific denomination","That the old self is dead and a new life in Christ has begun","That they will never sin again"], correct: 2, explanation: "Baptism is a public declaration of union with Christ — the old self crucified and buried, a new life raised with Christ." }
        ]
      },
      {
        id: "sac-2",
        title: "The Lord's Supper — Do This in Remembrance",
        scripture: "1 Corinthians 11:23-34; Luke 22:14-20",
        teaching: "Paul passes on what he received from the Lord: on the night He was betrayed, Jesus took bread, gave thanks, broke it and said 'This is my body, which is for you; do this in remembrance of me.' In the same way He took the cup after supper, saying 'This cup is the new covenant in my blood; do this, whenever you drink it, in remembrance of me.' Paul adds: 'For whenever you eat this bread and drink this cup, you proclaim the Lord's death until he comes.' The Lord's Supper looks backward (the cross), inward (self-examination), outward (proclaiming the Gospel), and forward (His return).",
        keyVerse: "For whenever you eat this bread and drink this cup, you proclaim the Lord's death until he comes. — 1 Corinthians 11:26",
        questions: [
          { question: "What does Jesus say the cup represents?", options: ["The blood of the Passover lamb","The new covenant in His blood","The Old Testament sacrificial system","The prayers of the saints"], correct: 1, explanation: "Luke 22:20 and 1 Corinthians 11:25 record Jesus saying 'This cup is the new covenant in my blood, which is poured out for you.'" },
          { question: "What four directions does the Lord's Supper point?", options: ["North, south, east, west","Creation, fall, redemption, restoration","Backward to the cross, inward in examination, outward in proclamation, forward to His return","Faith, hope, love, and repentance"], correct: 3, explanation: "The Lord's Supper remembers the cross (backward), requires self-examination (inward), proclaims the Gospel (outward), and anticipates His return (forward)." },
          { question: "What does Paul warn against regarding the Lord's Supper in 1 Corinthians 11?", options: ["Taking it too rarely","Taking it in an unworthy manner without self-examination","Taking it alone without the church","Taking it before breakfast"], correct: 1, explanation: "1 Corinthians 11:27-29 warns that eating the bread or drinking the cup 'in an unworthy manner' — without recognizing the body of Christ — brings judgment." }
        ]
      },
      {
        id: "sac-3",
        title: "Jesus' Own Baptism — All Righteousness Fulfilled",
        scripture: "Matthew 3:13-17; John 1:29-34",
        teaching: "When Jesus came to John to be baptized, John tried to stop Him: 'I need to be baptized by you, and do you come to me?' Jesus replied: 'Let it be so now; it is proper for us to do this to fulfill all righteousness.' Jesus had no sin requiring repentance — His baptism was an act of solidarity with sinful humanity and an identification with our need. As He came up out of the water, the heavens opened and the Spirit descended like a dove. The voice of the Father spoke: 'This is my Son, whom I love; with him I am well pleased.' All three persons of the Trinity were present — a Trinitarian moment.",
        keyVerse: "This is my Son, whom I love; with him I am well pleased. — Matthew 3:17",
        questions: [
          { question: "Why did John try to stop Jesus from being baptized?", options: ["He didn't believe Jesus was the Messiah","He felt unworthy and said Jesus should baptize him instead","John's baptism was only for Gentiles","John was afraid of a crowd reaction"], correct: 1, explanation: "Matthew 3:14 records John saying 'I need to be baptized by you, and do you come to me?' — recognizing Jesus' sinlessness." },
          { question: "Why did Jesus insist on being baptized?", options: ["He needed forgiveness like everyone else","To please His parents","To fulfill all righteousness — identifying with sinful humanity","To publicly launch His ministry only"], correct: 2, explanation: "Matthew 3:15 — 'to fulfill all righteousness' — Jesus identified with the humanity He came to save." },
          { question: "What makes Jesus' baptism a Trinitarian moment?", options: ["The crowd recited the Trinity formula","Jesus prayed to all three persons","The Son is baptized, the Spirit descends like a dove, and the Father's voice speaks","Three angels appeared"], correct: 2, explanation: "At Jesus' baptism: the Son is in the water, the Spirit descends as a dove, and the Father's voice declares 'This is my Son, whom I love.'" }
        ]
      }
    ]
  },

  // ─── FORGIVENESS AND RECONCILIATION ───────────────────────────────────────
  {
    id: "forgiveness",
    title: "Forgiveness & Reconciliation",
    description: "The power to release and restore",
    icon: "🤝",
    color: "from-green-400 to-teal-500",
    lessons: [
      {
        id: "forg-1",
        title: "The Unforgiving Servant",
        scripture: "Matthew 18:21-35",
        teaching: "Peter asked how many times he should forgive — seven times? Jesus replied: 'Not seven times, but seventy-seven times.' He told a parable: a king forgave a servant an enormous debt — ten thousand bags of gold. That same servant then refused to forgive a fellow servant who owed him a tiny amount — one hundred silver coins — and had him thrown in prison. The king summoned him in anger: 'Shouldn't you have had mercy on your fellow servant just as I had on you?' Jesus concludes: 'This is how my heavenly Father will treat each of you unless you forgive your brother or sister from your heart.'",
        keyVerse: "Shouldn't you have had mercy on your fellow servant just as I had on you? — Matthew 18:33",
        questions: [
          { question: "How many times did Jesus say to forgive?", options: ["Seven times","Seventy times","Seventy-seven times (or seventy times seven)","As many times as they ask"], correct: 2, explanation: "Matthew 18:22 — Jesus said 'not seven times, but seventy-seven times' (or 70x7 in some translations) — meaning limitless forgiveness." },
          { question: "What was the ratio between the two debts in the parable?", options: ["They were equal","The first was slightly larger","The first debt was astronomically larger — 10,000 bags of gold vs 100 silver coins","The second debt was larger"], correct: 2, explanation: "The contrast is enormous — 10,000 talents (gold bags) vs 100 denarii (silver coins). The servant was forgiven a debt he could never repay, then refused to forgive a tiny one." },
          { question: "What does Jesus teach about forgiving 'from the heart'?", options: ["That verbal forgiveness alone is enough","That forgiveness must be genuine, not merely formal or surface-level","That we must feel emotionally healed before we forgive","That we should only forgive those who apologize"], correct: 1, explanation: "Matthew 18:35 specifies 'from your heart' — Jesus calls for genuine, deep forgiveness, not mere outward compliance." }
        ]
      },
      {
        id: "forg-2",
        title: "Joseph Forgives His Brothers",
        scripture: "Genesis 45:1-15; 50:15-21",
        teaching: "After years of slavery and imprisonment caused by his brothers' jealousy, Joseph was exalted to second-in-command of Egypt. When his brothers came for grain during the famine, Joseph revealed himself weeping and said: 'I am Joseph! Come close to me... Do not be distressed and do not be angry with yourselves for selling me here, because it was to save lives that God sent me ahead of you.' He kissed all his brothers and wept over them. After their father Jacob died, the brothers feared Joseph would retaliate. He wept and said: 'You intended to harm me, but God intended it for good.' This is the highest model of forgiveness in the Old Testament.",
        keyVerse: "You intended to harm me, but God intended it for good to accomplish what is now being done, the saving of many lives. — Genesis 50:20",
        questions: [
          { question: "What was Joseph's first response when he revealed himself to his brothers?", options: ["He rebuked them sternly","He had them arrested","He wept aloud, kissed them, and told them not to be angry with themselves","He demanded repayment"], correct: 2, explanation: "Genesis 45:2-15 records Joseph weeping loudly, embracing his brothers, and immediately reassuring them that God had sent him ahead to save lives." },
          { question: "What did Joseph fear his brothers thought would happen after their father died?", options: ["They thought he would give them less food","They feared he would now take revenge","They thought he would sell them as slaves","They feared he would send them back to Canaan"], correct: 1, explanation: "Genesis 50:15 says 'When Joseph's brothers saw that their father was dead, they said, What if Joseph holds a grudge against us and pays us back for all the wrongs we did to him?'" },
          { question: "What theological perspective enabled Joseph to forgive so completely?", options: ["He had forgotten the past","Time had healed everything","He saw God's sovereign purpose working through even his brothers' evil actions","He was naturally a forgiving person"], correct: 2, explanation: "Genesis 50:20 — 'You intended to harm me, but God intended it for good' — Joseph's forgiveness was grounded in his understanding of God's sovereign providence." }
        ]
      },
      {
        id: "forg-3",
        title: "Forgiving from the Cross",
        scripture: "Luke 23:32-43",
        teaching: "As Jesus was being crucified — nailed to the cross in excruciating pain, mocked and taunted by crowds and rulers — He prayed: 'Father, forgive them, for they do not know what they are doing.' This is forgiveness at its most radical — extended from the very place of suffering, to those actively inflicting it. One of the criminals crucified with Him also mocked Him. But the other rebuked his companion, acknowledged his own guilt, and said 'Jesus, remember me when you come into your kingdom.' Jesus replied: 'Truly I tell you, today you will be with me in paradise.' Grace to the very end.",
        keyVerse: "Father, forgive them, for they do not know what they are doing. — Luke 23:34",
        questions: [
          { question: "When did Jesus pray 'Father, forgive them'?", options: ["Before His arrest in the garden","During His trial before Pilate","While He was being crucified","After the resurrection"], correct: 2, explanation: "Luke 23:33-34 places this prayer at the moment of crucifixion — Jesus prayed for His executioners while they were nailing Him to the cross." },
          { question: "What did the repentant criminal ask of Jesus?", options: ["Come down from the cross","Forgive my sins publicly","Remember me when you come into your kingdom","Save us all from death"], correct: 2, explanation: "Luke 23:42 — 'Then he said, Jesus, remember me when you come into your kingdom.'" },
          { question: "What promise did Jesus make to the repentant criminal?", options: ["His sins would be forgiven after death","He would be remembered in the resurrection","Today you will be with me in paradise","He would be raised from the dead too"], correct: 2, explanation: "Luke 23:43 — 'Jesus answered him, Truly I tell you, today you will be with me in paradise.'" }
        ]
      },
      {
        id: "forg-4",
        title: "Paul and Onesimus — Reconciliation in Practice",
        scripture: "Philemon 1-25",
        teaching: "Paul's shortest letter is also one of the most personal. Onesimus was a slave who had apparently stolen from his master Philemon and run away. He encountered Paul in prison and was converted. Paul sends him back with this letter, calling Onesimus 'my very heart' and asking Philemon to receive him back — not as a slave but as a dear brother in Christ. Paul even offers to pay any debt Onesimus owes, adding 'not to mention that you owe me your very self.' This letter is a real-life example of forgiveness, reconciliation, and the transforming power of the Gospel on social relationships.",
        keyVerse: "No longer as a slave, but better than a slave, as a dear brother. — Philemon 1:16",
        questions: [
          { question: "Who was Onesimus in relation to Philemon?", options: ["His son","His business partner","His runaway slave","His church elder"], correct: 2, explanation: "Onesimus was Philemon's slave who had apparently run away (and possibly stolen from him) before encountering Paul and being converted." },
          { question: "How does Paul ask Philemon to receive Onesimus back?", options: ["As a slave with reduced duties","As a servant of the church","No longer as a slave but as a dear brother in Christ","With formal legal reinstatement"], correct: 2, explanation: "Philemon 1:16 — Paul asks Philemon to receive Onesimus 'no longer as a slave, but better than a slave, as a dear brother.'" },
          { question: "What does Paul offer to do regarding Onesimus' debt?", options: ["He asks the church to pay it","He says God has forgiven all debts","He personally offers to pay whatever Onesimus owes","He argues no debt is legally binding"], correct: 2, explanation: "Philemon 1:18-19 — Paul writes 'if he has done you any wrong or owes you anything, charge it to me. I, Paul, am writing this with my own hand — I will pay it back.'" }
        ]
      }
    ]
  },

  // ─── STEWARDSHIP AND MONEY ────────────────────────────────────────────────
  {
    id: "stewardship",
    title: "Money & Stewardship",
    description: "Faithful management of what God gives",
    icon: "💰",
    color: "from-yellow-500 to-orange-500",
    lessons: [
      {
        id: "st-1",
        title: "The Parable of the Talents",
        scripture: "Matthew 25:14-30",
        teaching: "A man going on a journey entrusted his servants with different amounts of money — five talents, two, and one — each according to his ability. The first two doubled what they had and were praised: 'Well done, good and faithful servant! You have been faithful with a few things; I will put you in charge of many things.' The third buried his talent out of fear and returned only what he had received. The master was angry: 'You wicked, lazy servant!' The talent was taken from him. Faithfulness and wise stewardship of what God gives — however much or little — is expected of every believer.",
        keyVerse: "Well done, good and faithful servant! You have been faithful with a few things; I will put you in charge of many things. — Matthew 25:21",
        questions: [
          { question: "Why did the third servant bury his talent?", options: ["He wanted to keep it safe as a savings plan","He was afraid and knew his master was a hard man","He thought one talent was too little to invest","He planned to invest it later"], correct: 1, explanation: "Matthew 25:25 — 'I was afraid and went out and hid your gold in the ground.'" },
          { question: "What was the master's response to the two faithful servants?", options: ["He gave them the buried talent too","Well done, good and faithful servant — enter your master's happiness","He made them managers immediately","He praised them privately"], correct: 1, explanation: "Matthew 25:21 — 'Well done, good and faithful servant! You have been faithful with a few things; I will put you in charge of many things. Come and share your master's happiness!'" },
          { question: "What principle about stewardship does this parable teach?", options: ["The amount given is what matters most","Faithfulness in using what God entrusts — however much or little — is required","Only public investing counts","Burying resources is sometimes the right choice"], correct: 1, explanation: "Each servant received 'each according to his ability' — different amounts, but all were expected to faithfully use what they were given." }
        ]
      },
      {
        id: "st-2",
        title: "The Rich Young Ruler",
        scripture: "Mark 10:17-31",
        teaching: "A wealthy young man ran up to Jesus and asked what he must do to inherit eternal life. Jesus listed commandments; the man said he'd kept them all. Jesus looked at him and loved him, then said: 'One thing you lack. Go, sell everything you have and give to the poor... Then come, follow me.' The man's face fell and he went away sad, because he had great wealth. Jesus said it was harder for a rich man to enter the kingdom than for a camel to go through the eye of a needle. The disciples asked who then can be saved. Jesus replied: 'With man this is impossible, but not with God; all things are possible with God.'",
        keyVerse: "With man this is impossible, but not with God; all things are possible with God. — Mark 10:27",
        questions: [
          { question: "What is significant about Jesus' response before asking the young man to sell everything?", options: ["Jesus was testing him to see if he'd obey","Jesus looked at him and loved him — it was a command of love, not condemnation","Jesus knew the man would refuse","Jesus was speaking only to this specific man, not everyone"], correct: 1, explanation: "Mark 10:21 specifically notes 'Jesus looked at him and loved him' — this command came from love, not judgment." },
          { question: "Why did the young man go away sad?", options: ["He was afraid of poverty","He didn't believe eternal life was real","He had great wealth and was unwilling to surrender it","He needed more time to decide"], correct: 2, explanation: "Mark 10:22 says he 'went away sad, because he had great wealth' — his possessions had a hold on his heart." },
          { question: "What does Jesus teach about wealth and the kingdom of God?", options: ["Wealth disqualifies a person from salvation","Generosity automatically earns salvation","With human effort, wealth makes kingdom entry nearly impossible — but with God all things are possible","Wealthy people need to give only a percentage"], correct: 2, explanation: "Jesus says it is very difficult (like a camel through a needle's eye), but immediately qualifies: 'all things are possible with God' — salvation is entirely God's work." }
        ]
      },
      {
        id: "st-3",
        title: "Tithing and Generosity",
        scripture: "Malachi 3:10; 2 Corinthians 9:6-8; Luke 21:1-4",
        teaching: "God challenged Israel through Malachi: 'Bring the whole tithe into the storehouse... Test me in this, says the Lord Almighty, and see if I will not throw open the floodgates of heaven and pour out so much blessing that there will not be room enough to store it.' The tithe — a tenth — was the baseline standard of Old Testament giving. Paul in 2 Corinthians moves from minimum to maximum: give what you have decided in your heart, not reluctantly or under compulsion, for 'God loves a cheerful giver.' Jesus observed that the widow gave from her poverty — true generosity is a matter of heart and proportion, not amount.",
        keyVerse: "Test me in this, says the Lord Almighty, and see if I will not throw open the floodgates of heaven. — Malachi 3:10",
        questions: [
          { question: "What does God invite Israel to do in Malachi 3:10 regarding giving?", options: ["Give as much as possible","Tithe to become wealthy","Test Him with the whole tithe and see the blessing He pours out","Give secretly to avoid pride"], correct: 2, explanation: "Malachi 3:10 — 'Test me in this, says the Lord Almighty, and see if I will not throw open the floodgates of heaven and pour out so much blessing.'" },
          { question: "What is a tithe?", options: ["A voluntary offering of any amount","A fifth of all income","A tenth of one's income or produce","A special offering at Passover"], correct: 2, explanation: "The tithe (Hebrew: ma'aser) means 'a tenth' — it was the baseline standard of giving in Old Testament Israel." },
          { question: "What attitude does Paul say God loves in giving?", options: ["Giving out of fear of punishment","Giving cheerfully — not reluctantly or under compulsion","Giving anonymously always","Giving publicly for accountability"], correct: 1, explanation: "2 Corinthians 9:7 — 'God loves a cheerful giver' — the attitude of the heart matters more than the amount." }
        ]
      }
    ]
  },

  // ─── THE PSALMS OF ASCENT ─────────────────────────────────────────────────
  {
    id: "psalms-ascent",
    title: "Songs of Ascent",
    description: "Psalms 120-134 — pilgrim songs",
    icon: "🎵",
    color: "from-violet-400 to-blue-500",
    lessons: [
      {
        id: "ps-1",
        title: "Psalm 121 — My Help Comes from the Lord",
        scripture: "Psalm 121",
        teaching: "Psalm 121 was sung by pilgrims traveling up to Jerusalem for the great feasts. 'I lift up my eyes to the mountains — where does my help come from? My help comes from the Lord, the Maker of heaven and earth.' The hills could refer to the mountains around Jerusalem or possibly pagan shrines on hilltops. Either way, the answer is clear: true help does not come from geography, nature, or idols — it comes from the Creator of all. The psalm closes with a remarkable promise: the Lord watches over your life going out and coming in, from this time forth and even forevermore.",
        keyVerse: "My help comes from the Lord, the Maker of heaven and earth. — Psalm 121:2",
        questions: [
          { question: "Who did the pilgrims sing this psalm as they climbed toward?", options: ["Mount Sinai","The mountains in general","Jerusalem for the great feasts","Mount Carmel"], correct: 2, explanation: "Psalms 120-134 are called 'Songs of Ascent' — sung by pilgrims as they traveled up to Jerusalem for the three great annual feasts." },
          { question: "How does Psalm 121 describe the Lord as Israel's keeper?", options: ["He sleeps sometimes but watches mostly","He will neither slumber nor sleep","He watches from a distance","He keeps only the righteous"], correct: 1, explanation: "Psalm 121:4 says 'he who watches over Israel will neither slumber nor sleep' — God is always awake and attentive." },
          { question: "What does Psalm 121 say the Lord watches over?", options: ["Only the temple and priests","Only Israel as a nation","Your going out and your coming in, from now and forevermore","Only your spiritual life"], correct: 2, explanation: "Psalm 121:8 says 'the Lord will watch over your coming and going both now and forevermore.'" }
        ]
      },
      {
        id: "ps-2",
        title: "Psalm 130 — Out of the Depths",
        scripture: "Psalm 130",
        teaching: "One of the most beloved penitential psalms: 'Out of the depths I cry to you, Lord; Lord, hear my voice. Let your ears be attentive to my cry for mercy.' The psalmist acknowledges that if God kept a record of sins, no one could stand. But with God there is forgiveness — so that He is feared. The soul waits for the Lord more than watchmen wait for the morning — watchmen standing through the cold darkness, knowing dawn is certain. Israel is called to hope in the Lord because with Him is unfailing love and full redemption. He will redeem Israel from all their sins.",
        keyVerse: "If you, Lord, kept a record of sins, Lord, who could stand? But with you there is forgiveness, so that we can, with reverence, serve you. — Psalm 130:3-4",
        questions: [
          { question: "What does the psalmist cry from 'the depths'?", options: ["A prayer for revenge","A request for wealth","A cry for mercy from God who hears and forgives","A song of praise"], correct: 2, explanation: "Psalm 130:1-2 — 'Out of the depths I cry to you, Lord; Lord, hear my voice. Let your ears be attentive to my cry for mercy.'" },
          { question: "What would happen if God kept a record of all our sins?", options: ["Only the righteous would stand","Most people would fall but not all","No one could stand before Him","Only Old Testament saints would be affected"], correct: 2, explanation: "Psalm 130:3 — 'If you, Lord, kept a record of sins, Lord, who could stand?' — no one. God's forgiveness is the only hope." },
          { question: "To what does the psalmist compare waiting on the Lord?", options: ["Waiting for rain after a drought","Watching the sunset","Watchmen waiting for the morning — with certainty that dawn will come","Children waiting for a parent to return"], correct: 2, explanation: "Psalm 130:6 — 'I wait for the Lord more than watchmen wait for the morning, more than watchmen wait for the morning.'" }
        ]
      },
      {
        id: "ps-3",
        title: "Psalm 133 — The Beauty of Unity",
        scripture: "Psalm 133",
        teaching: "One of the shortest psalms is also one of the most powerful about community: 'How good and pleasant it is when God's people live together in unity!' The psalmist uses two vivid images: precious oil poured on Aaron's head running down his beard — the anointing of the High Priest blessing the whole community. And dew falling on Mount Hermon descending on Mount Zion — refreshing and life-giving moisture. The final verse ties unity to blessing: 'For there the Lord bestows his blessing, even life forevermore.' Where true unity exists among God's people, God commands His blessing.",
        keyVerse: "How good and pleasant it is when God's people live together in unity! — Psalm 133:1",
        questions: [
          { question: "What two images does Psalm 133 use to describe unity?", options: ["Rain and sunshine","A mountain and a valley","Precious oil poured on Aaron and dew descending from Mount Hermon","A fire and a river"], correct: 2, explanation: "Psalm 133:2-3 uses precious oil (Aaron's anointing) and Mount Hermon dew — both images of abundant, life-giving blessing flowing from above." },
          { question: "What does God bestow where unity exists?", options: ["Earthly wealth","Military victory","His blessing — even life forevermore","Political stability"], correct: 2, explanation: "Psalm 133:3 says 'For there the Lord bestows his blessing, even life forevermore' — God's blessing is commanded where unity dwells." },
          { question: "What are the two qualities that describe Christian unity in verse 1?", options: ["Powerful and enduring","Holy and righteous","Good and pleasant","Strong and faithful"], correct: 2, explanation: "Psalm 133:1 — 'How good and pleasant it is when God's people live together in unity!' — good (morally right) and pleasant (agreeable, joyful)." }
        ]
      }
    ]
  },

  // ─── COVENANT THEOLOGY ────────────────────────────────────────────────────
  {
    id: "covenants",
    title: "God's Covenants",
    description: "The story of redemption through covenants",
    icon: "🌿",
    color: "from-emerald-400 to-green-600",
    lessons: [
      {
        id: "cov-1",
        title: "The Noahic Covenant",
        scripture: "Genesis 9:1-17",
        teaching: "After the flood, God made a covenant with Noah, his descendants, and every living creature. God promised never again to destroy all life by flood. The sign was a rainbow in the clouds — whenever God sees the rainbow, He will remember His covenant. This is a universal covenant with all creation, not just Israel. It is unconditional — God makes it without requiring anything from Noah's side. It represents God's commitment to maintaining creation for the purposes of redemption. The Noahic covenant establishes the stability of the natural world that makes the history of salvation possible.",
        keyVerse: "I have set my rainbow in the clouds, and it will be the sign of the covenant between me and the earth. — Genesis 9:13",
        questions: [
          { question: "With whom did God make the Noahic covenant?", options: ["Noah alone","Noah and Israel","Noah, all his descendants, and every living creature","Only the righteous of every generation"], correct: 2, explanation: "Genesis 9:9-10 says 'I now establish my covenant with you and with your descendants after you and with every living creature.'" },
          { question: "What was the sign of the Noahic covenant?", options: ["Circumcision","The Sabbath","The rainbow","An altar of sacrifice"], correct: 2, explanation: "Genesis 9:13 — 'I have set my rainbow in the clouds, and it will be the sign of the covenant between me and the earth.'" },
          { question: "Is the Noahic covenant conditional or unconditional?", options: ["Conditional on Israel's obedience","Conditional on global righteousness","Unconditional — God makes the promise without requiring anything from Noah","Conditional on regular sacrifice"], correct: 2, explanation: "The Noahic covenant is entirely one-sided — God makes the promise without requiring a response from Noah. It is a covenant of grace." }
        ]
      },
      {
        id: "cov-2",
        title: "The Mosaic Covenant",
        scripture: "Exodus 19-20; Deuteronomy 28",
        teaching: "At Mount Sinai, God made a covenant with Israel as a nation. He reminded them: 'I carried you on eagles' wings and brought you to myself. Now if you obey me fully and keep my covenant, then out of all nations you will be my treasured possession.' Unlike the Abrahamic covenant, this was conditional — Israel's blessing depended on obedience. Deuteronomy 28 lists blessings for obedience and curses for disobedience. The Mosaic covenant was never intended to save — Paul says it was added 'because of transgressions until the Seed (Christ) to whom the promise referred had come' (Galatians 3:19). It reveals our need for a Savior.",
        keyVerse: "You will be for me a kingdom of priests and a holy nation. — Exodus 19:6",
        questions: [
          { question: "What was the condition of the Mosaic covenant?", options: ["It was unconditional like the Abrahamic","Full obedience to God's commands — blessings for obedience, curses for disobedience","Payment of regular tithes","Building the tabernacle exactly as commanded"], correct: 1, explanation: "Exodus 19:5-6 — 'if you obey me fully and keep my covenant... you will be my treasured possession.' Deuteronomy 28 details blessings and curses based on obedience." },
          { question: "What does Paul say the purpose of the Mosaic law was?", options: ["To provide a way of salvation","To establish Israel as superior to other nations","It was added because of transgressions until Christ came — to reveal our need for a Savior","To prepare Israel for military conquest"], correct: 2, explanation: "Galatians 3:19 and 3:24 — the law was a 'guardian' to lead us to Christ, not a means of salvation." },
          { question: "What title does God give Israel in the Mosaic covenant?", options: ["A holy army","A royal lineage","A kingdom of priests and a holy nation","The firstborn of all nations"], correct: 2, explanation: "Exodus 19:6 — 'you will be for me a kingdom of priests and a holy nation' — a mediating, representative people for God." }
        ]
      },
      {
        id: "cov-3",
        title: "The Davidic Covenant",
        scripture: "2 Samuel 7:8-17; Psalm 89:1-4",
        teaching: "King David wanted to build a temple for God. Through the prophet Nathan, God responded with an extraordinary promise: David would not build God a house — but God would build David a house (dynasty). 'Your house and your kingdom will endure forever before me; your throne will be established forever.' One of David's descendants would reign on the throne forever. This is the covenant Paul references in Acts 13:23 — 'From this man's descendants God has brought to Israel the Savior Jesus.' Jesus is the fulfillment of the Davidic covenant — the eternal king descended from David, announced as 'Son of David' throughout the Gospels.",
        keyVerse: "Your house and your kingdom will endure forever before me; your throne will be established forever. — 2 Samuel 7:16",
        questions: [
          { question: "What did David want to do for God?", options: ["Write new psalms","Conquer all of Canaan","Build God a temple (house)","Establish the priesthood"], correct: 2, explanation: "2 Samuel 7:2 — David said to Nathan 'Here I am, living in a house of cedar, while the ark of God remains in a tent.' He wanted to build God a proper temple." },
          { question: "What was God's response to David's desire to build a temple?", options: ["He approved the plan immediately","He said David must build it before he died","He said not David but his son would build it, and God would build David an eternal dynasty","He rejected the idea entirely"], correct: 2, explanation: "2 Samuel 7:12-13 — God would have David's son build the temple, and God would establish David's kingdom forever through his descendants." },
          { question: "How does Jesus fulfill the Davidic covenant?", options: ["By rebuilding the physical temple","By becoming a Jewish king in Jerusalem","By being the eternal king descended from David, fulfilling the promise of an everlasting throne","By reinterpreting the covenant to be spiritual only"], correct: 2, explanation: "Luke 1:32-33 — Gabriel tells Mary her son Jesus 'will be great and will be called the Son of the Most High. The Lord God will give him the throne of his father David, and he will reign over Jacob's descendants forever.'" }
        ]
      },
      {
        id: "cov-4",
        title: "The New Covenant",
        scripture: "Jeremiah 31:31-34; Hebrews 8:6-13",
        teaching: "Jeremiah prophesied a new covenant coming: 'The days are coming, declares the Lord, when I will make a new covenant with the people of Israel... I will put my law in their minds and write it on their hearts. I will be their God, and they will be my people.' Unlike the Mosaic covenant written on stone and broken repeatedly, the new covenant would be internal and personal. 'I will forgive their wickedness and will remember their sins no more.' Jesus inaugurated this covenant at the Last Supper: 'This cup is the new covenant in my blood.' The author of Hebrews quotes Jeremiah at length, saying this new covenant has made the old one obsolete.",
        keyVerse: "I will put my law in their minds and write it on their hearts. I will be their God, and they will be my people. — Jeremiah 31:33",
        questions: [
          { question: "What is the key difference between the old and new covenants?", options: ["The new covenant requires more obedience","The old was written on stone; the new is written on hearts and minds","The new covenant is only for Gentiles","The old covenant was better but temporary"], correct: 1, explanation: "Jeremiah 31:33 — the new covenant is internal: 'I will put my law in their minds and write it on their hearts' — not external stone tablets." },
          { question: "What does God promise about sins under the new covenant?", options: ["They will be limited to unintentional sins","They will require annual sacrifice","I will forgive their wickedness and remember their sins no more","They will be reduced but not eliminated"], correct: 2, explanation: "Jeremiah 31:34 — 'For I will forgive their wickedness and will remember their sins no more' — complete and final forgiveness." },
          { question: "When did Jesus inaugurate the new covenant?", options: ["At His baptism","On the Mount of Transfiguration","At the Last Supper — 'This cup is the new covenant in my blood'","After His resurrection"], correct: 2, explanation: "Luke 22:20 records Jesus saying 'This cup is the new covenant in my blood, which is poured out for you' — inaugurating Jeremiah's prophecy." }
        ]
      }
    ]
  }
];