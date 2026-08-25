-- Refresh Umrah & Hajj guide steps for accordion UI.
-- Copy is CMS-owned (guide_steps + pilgrimage_hub). Step images are App Media slots.

DELETE FROM public.guide_steps
WHERE guide_slug IN ('umrah', 'hajj');

INSERT INTO public.guide_steps (
  guide_slug, title, body, subtitle, description, arabic, arabic_en, published, sort_order
) VALUES
  (
    'umrah',
    'Before Assuming Ihram',
    '{"subtitle": "Ghusl · Niyyah · Settle your affairs", "desc": "Congratulations, you are a guest of Allah (swt). Prepare yourself in the best possible way, as you are about to visit the most sacred building in the world – the first Masjid built for the worship of Allah.\n\nYou may need to do Ghusl (bath) or Wudu (ablution) before wearing Ihram. Men can also apply Attar (perfume) to their hair or beard at this stage (if not yet in Ihram).\n\n**Note:** You can put on your Ihram garment beforehand (physically wearing it), but you only enter the \"state of Ihram\" when you make the intention at the Miqat point.\n\n**Once you enter the State of Ihram, you must not:**\n\n- Cut or pluck your hair\n- Use perfume or scented items\n- Wear any stitched clothes (men only)\n- Cover your head (men only)\n- Trim your nails\n- Hunt animals\n- Smoke or take drugs\n- Engage in quarrels or fights", "arabic": "الإحرام"}',
    'Ghusl · Niyyah · Settle your affairs',
    'Congratulations, you are a guest of Allah (swt). Prepare yourself in the best possible way, as you are about to visit the most sacred building in the world – the first Masjid built for the worship of Allah.

You may need to do Ghusl (bath) or Wudu (ablution) before wearing Ihram. Men can also apply Attar (perfume) to their hair or beard at this stage (if not yet in Ihram).

**Note:** You can put on your Ihram garment beforehand (physically wearing it), but you only enter the "state of Ihram" when you make the intention at the Miqat point.

**Once you enter the State of Ihram, you must not:**

- Cut or pluck your hair
- Use perfume or scented items
- Wear any stitched clothes (men only)
- Cover your head (men only)
- Trim your nails
- Hunt animals
- Smoke or take drugs
- Engage in quarrels or fights',
    'الإحرام',
    NULL,
    true,
    1
  ),
  (
    'umrah',
    'Change into Your Ihram',
    '{"subtitle": "Men: two white cloths · Women: modest dress", "desc": "**Men**\n\nWear two white sheets (Ihram): one wrapped around the waist and the other draped over the upper body. Slippers should be worn that do not cover the ankles, but hats, turbans, or any head coverings are not permitted.\n\n**Women**\n\nMay wear their usual modest clothing, but must avoid wearing gloves or covering their face (unless in front of non-Mahram men if they usually wear niqab).\n\n**You must:**\n\n- Ensure you change into your Ihram attire before crossing the Miqat\n- If traveling by plane to Arabia, enter into Ihram before departure or during a stopover\n- If you can, try to combine wearing the Ihram with an obligatory or optional prayer", "arabic": "لباس الإحرام"}',
    'Men: two white cloths · Women: modest dress',
    '**Men**

Wear two white sheets (Ihram): one wrapped around the waist and the other draped over the upper body. Slippers should be worn that do not cover the ankles, but hats, turbans, or any head coverings are not permitted.

**Women**

May wear their usual modest clothing, but must avoid wearing gloves or covering their face (unless in front of non-Mahram men if they usually wear niqab).

**You must:**

- Ensure you change into your Ihram attire before crossing the Miqat
- If traveling by plane to Arabia, enter into Ihram before departure or during a stopover
- If you can, try to combine wearing the Ihram with an obligatory or optional prayer',
    'لباس الإحرام',
    NULL,
    true,
    2
  ),
  (
    'umrah',
    'Make the Intention for Umrah',
    '{"subtitle": "Miqat is 20–30 min before landing", "desc": "For those flying from abroad, the Miqat point is usually passed about 20–30 minutes before landing. They may announce this, or you can track it yourself. At this point, make the intention for Umrah.\n\n> لَبَّيْكَ اللَّهُمَّ عُمْرَةً\n>\n> Labbayk Allahumma Umrah.\n>\n> Here I am O Allah making Umrah.\n\n**Optional Du''a:**\n\n> اللَّهُمَّ هَذِهِ عُمْرَةٌ لَا رِيَاءَ فِيهَا وَلَا سُمْعَةَ\n>\n> Allahumma hādhihi ''Umrah, lā riyā''a feehā wa lā sum''ah.\n>\n> O Allah this is an Umrah, there is no showing off in it nor seeking reputation.", "arabic": "النية عند الميقات"}',
    'Miqat is 20–30 min before landing',
    'For those flying from abroad, the Miqat point is usually passed about 20–30 minutes before landing. They may announce this, or you can track it yourself. At this point, make the intention for Umrah.

> لَبَّيْكَ اللَّهُمَّ عُمْرَةً
>
> Labbayk Allahumma Umrah.
>
> Here I am O Allah making Umrah.

**Optional Du''a:**

> اللَّهُمَّ هَذِهِ عُمْرَةٌ لَا رِيَاءَ فِيهَا وَلَا سُمْعَةَ
>
> Allahumma hādhihi ''Umrah, lā riyā''a feehā wa lā sum''ah.
>
> O Allah this is an Umrah, there is no showing off in it nor seeking reputation.',
    'النية عند الميقات',
    NULL,
    true,
    3
  ),
  (
    'umrah',
    'Recite the Talbiyah',
    '{"subtitle": "Men: loud · Women: softly · Until Tawaf", "desc": "Men should recite this in a loud voice, while women should recite it softly. Continue until you reach Masjid al-Haram in Makkah.\n\n> لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ\n>\n> Labbayka Allahumma labbayka, labbayka la sharika laka labbayka, inna l-hamda wa n-ni''mata laka w-al-mulk, la sharika lak.\n>\n> At your service, Allah, at your service. You have no partner; at your service. Truly all praise, favor and sovereignty are Yours; You have no partner.\n\n**Hadith:** \"When any pilgrim utters Talbiyah, everything on his right and left, whether it be stones, trees, or clay, joins him in his statement.\" [Sahih Muslim 1184]", "arabic": "التلبية"}',
    'Men: loud · Women: softly · Until Tawaf',
    'Men should recite this in a loud voice, while women should recite it softly. Continue until you reach Masjid al-Haram in Makkah.

> لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ
>
> Labbayka Allahumma labbayka, labbayka la sharika laka labbayka, inna l-hamda wa n-ni''mata laka w-al-mulk, la sharika lak.
>
> At your service, Allah, at your service. You have no partner; at your service. Truly all praise, favor and sovereignty are Yours; You have no partner.

**Hadith:** "When any pilgrim utters Talbiyah, everything on his right and left, whether it be stones, trees, or clay, joins him in his statement." [Sahih Muslim 1184]',
    'التلبية',
    NULL,
    true,
    4
  ),
  (
    'umrah',
    'Entering Masjid Al-Haram',
    '{"subtitle": "Enter with right foot · Recite du''a", "desc": "Enter the Masjid Al-Haram (the Sacred Mosque) with your **right foot first** and recite:\n\n> اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ\n>\n> Allāhumma ṣalli ''alā Muḥammadin wa sallim. Allāhumma iftaḥ-lee abwāba raḥmatika.\n>\n> O Allah, send peace upon Muhammad. O Allah open the doors of Your Mercy for me.\n\nAvoid distractions from devices and the busy crowds. Rather, focus on your Lord and the significance of your journey.", "arabic": "دخول المسجد الحرام"}',
    'Enter with right foot · Recite du''a',
    'Enter the Masjid Al-Haram (the Sacred Mosque) with your **right foot first** and recite:

> اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَسَلِّمْ اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ
>
> Allāhumma ṣalli ''alā Muḥammadin wa sallim. Allāhumma iftaḥ-lee abwāba raḥmatika.
>
> O Allah, send peace upon Muhammad. O Allah open the doors of Your Mercy for me.

Avoid distractions from devices and the busy crowds. Rather, focus on your Lord and the significance of your journey.',
    'دخول المسجد الحرام',
    NULL,
    true,
    5
  ),
  (
    'umrah',
    'Performing Tawaf',
    '{"subtitle": "State of Wudu · Men: Iztiba''", "desc": "Make sure you are in a state of Wudu and walk towards the Mataf area (i.e. where people are walking around the Ka''bah).\n\n**Men — Iztiba''**\n\nUncover your right shoulder (known as Iztiba'') before starting Tawaf.", "arabic": "التهيؤ للطواف"}',
    'State of Wudu · Men: Iztiba''',
    'Make sure you are in a state of Wudu and walk towards the Mataf area (i.e. where people are walking around the Ka''bah).

**Men — Iztiba''**

Uncover your right shoulder (known as Iztiba'') before starting Tawaf.',
    'التهيؤ للطواف',
    NULL,
    true,
    6
  ),
  (
    'umrah',
    'Start Tawaf',
    '{"subtitle": "Black Stone · Bismillah Allahu Akbar · 7 circuits", "desc": "Start at Al-Hajr Al-Aswad (the Black Stone). If you look to your right (away from the Ka''bah) you will see green-fluorescent light. This is your starting point.\n\n> بِسْمِ اللهِ اللهُ أَكْبَرُ\n>\n> Bismillah Allahu Akbar\n>\n> Allah is the Greatest.\n\nTry touching the Black Stone (or kissing it) — if you cannot, make a sign with your right hand towards it. You will complete **7 tawafs (circuits)**. On the first three circuits, men should perform Raml (walking briskly).\n\nYou can make any supplication, say words of Dhikr or recite Qur''an — it is your choice. You are in front of Allah, the Creator of the Universe.", "arabic": "بدء الطواف"}',
    'Black Stone · Bismillah Allahu Akbar · 7 circuits',
    'Start at Al-Hajr Al-Aswad (the Black Stone). If you look to your right (away from the Ka''bah) you will see green-fluorescent light. This is your starting point.

> بِسْمِ اللهِ اللهُ أَكْبَرُ
>
> Bismillah Allahu Akbar
>
> Allah is the Greatest.

Try touching the Black Stone (or kissing it) — if you cannot, make a sign with your right hand towards it. You will complete **7 tawafs (circuits)**. On the first three circuits, men should perform Raml (walking briskly).

You can make any supplication, say words of Dhikr or recite Qur''an — it is your choice. You are in front of Allah, the Creator of the Universe.',
    'بدء الطواف',
    NULL,
    true,
    7
  ),
  (
    'umrah',
    'Yemeni Corner',
    '{"subtitle": "Recite Rabbana ātina each time you pass", "desc": "Each time you pass the Yemeni corner of the Ka''bah (the corner before the corner of the Black Stone), recite:\n\n> رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n>\n> Rabbana ātina fi d-dunyā ḥasanatan wa fi l-ākhirati ḥasanatan wa qinā ''adhāba n-nār.\n>\n> O our Lord, grant us the good of this world, the good of the Hereafter, and save us from the punishment of the fire.", "arabic": "الركن اليماني"}',
    'Recite Rabbana ātina each time you pass',
    'Each time you pass the Yemeni corner of the Ka''bah (the corner before the corner of the Black Stone), recite:

> رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ
>
> Rabbana ātina fi d-dunyā ḥasanatan wa fi l-ākhirati ḥasanatan wa qinā ''adhāba n-nār.
>
> O our Lord, grant us the good of this world, the good of the Hereafter, and save us from the punishment of the fire.',
    'الركن اليماني',
    NULL,
    true,
    8
  ),
  (
    'umrah',
    'Complete 7 Circuits',
    '{"subtitle": "Count from first complete circuit", "desc": "**Note:** Ensure you complete 7 circuits counting the first one after you had completed the tawaf, not counting it from the beginning.", "arabic": "إتمام الطواف"}',
    'Count from first complete circuit',
    '**Note:** Ensure you complete 7 circuits counting the first one after you had completed the tawaf, not counting it from the beginning.',
    'إتمام الطواف',
    NULL,
    true,
    9
  ),
  (
    'umrah',
    'After Tawaf',
    '{"subtitle": "Maqam Ibrahim · 2 Rak''ahs", "desc": "After performing Tawaf, proceed to the Maqam Ibrahim and recite the following verse (men should cover both shoulders at this point):\n\n> وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى\n>\n> Wattakhidhoo min Maqaami Ibraheema musalla.\n>\n> And take the Maqam Ibrahim as a place of Salah.\n\nPray **2 Rak''ahs** behind Maqam Ibrahim if possible, otherwise as close as possible. Recite **Surah Al-Kafirun** in the first Rak''ah and **Surah Al-Ikhlas** in the second.", "arabic": "بعد الطواف"}',
    'Maqam Ibrahim · 2 Rak''ahs',
    'After performing Tawaf, proceed to the Maqam Ibrahim and recite the following verse (men should cover both shoulders at this point):

> وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى
>
> Wattakhidhoo min Maqaami Ibraheema musalla.
>
> And take the Maqam Ibrahim as a place of Salah.

Pray **2 Rak''ahs** behind Maqam Ibrahim if possible, otherwise as close as possible. Recite **Surah Al-Kafirun** in the first Rak''ah and **Surah Al-Ikhlas** in the second.',
    'بعد الطواف',
    NULL,
    true,
    10
  ),
  (
    'umrah',
    'Drink Zamzam',
    '{"subtitle": "Make du''a · Pour over your head", "desc": "Then go to the Zamzam taps and drink from it and pour some of the water over your head. Make plenty of supplication for good when drinking Zamzam.\n\nThe Prophet ﷺ is reported to have said: \"It [Zamzam] is blessed, it is nourishment that satisfies and a cure for sickness.\" (Sahih Muslim)", "arabic": "شرب ماء زمزم"}',
    'Make du''a · Pour over your head',
    'Then go to the Zamzam taps and drink from it and pour some of the water over your head. Make plenty of supplication for good when drinking Zamzam.

The Prophet ﷺ is reported to have said: "It [Zamzam] is blessed, it is nourishment that satisfies and a cure for sickness." (Sahih Muslim)',
    'شرب ماء زمزم',
    NULL,
    true,
    11
  ),
  (
    'umrah',
    'Make Your Way to Mount Safa',
    '{"subtitle": "Recite the verse of Safa & Marwah", "desc": "As you ascend towards Safa, recite:\n\n> إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللهَ شَاكِرٌ عَلِيمٌ — نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ\n>\n> Innas-Safaa wal-Marwata min sha''aa''irillah… Nabda''u bimaa bada''Allahu bihi.\n>\n> Verily Safa and Marwah are from the signs of Allah… I begin with what Allah begins with.\n\nProceed to climb Mount Safa, face the Ka''bah if possible, and make any personal supplication or du''a you wish. You can repeat this du''a each time you ascend Safa and Marwah.", "arabic": "الصعود إلى الصفا"}',
    'Recite the verse of Safa & Marwah',
    'As you ascend towards Safa, recite:

> إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللهَ شَاكِرٌ عَلِيمٌ — نَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ
>
> Innas-Safaa wal-Marwata min sha''aa''irillah… Nabda''u bimaa bada''Allahu bihi.
>
> Verily Safa and Marwah are from the signs of Allah… I begin with what Allah begins with.

Proceed to climb Mount Safa, face the Ka''bah if possible, and make any personal supplication or du''a you wish. You can repeat this du''a each time you ascend Safa and Marwah.',
    'الصعود إلى الصفا',
    NULL,
    true,
    12
  ),
  (
    'umrah',
    'Upon Reaching Safa',
    '{"subtitle": "Face Ka''bah · Allahu Akbar · Lā ilāha illAllāh", "desc": "Face the direction of the Ka''bah and say:\n\n> اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ\n>\n> Allāhu akbar, Allāhu akbar, Allāhu akbar.\n>\n> Allah is the Greatest, Allah is the Greatest, Allah is the Greatest.\n\nThen:\n\n> لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ\n>\n> Lā ilāha illAllāh wahdahu lā shareekalah, lahul mulk, wa lahul-hamd, yuhyee wa yumeet—wa huwa ''ala kulli shay''in qadeer. Lā ilāha illAllāh wahdahu lā shareekalah, anjaza wa''dahu, wa nasara ''abdahu, wa hazamal ahzāba wahdah.\n>\n> There is none worthy of worship except Allāh alone, without partner. To Him belongs all sovereignty and all praise. He alone gives life and death—and He is All-Powerful over everything. There is none worthy of worship except Allāh alone, without partner. He has fulfilled His promise, aided His servant, He alone has defeated the confederates.", "arabic": "عند الصفا"}',
    'Face Ka''bah · Allahu Akbar · Lā ilāha illAllāh',
    'Face the direction of the Ka''bah and say:

> اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ
>
> Allāhu akbar, Allāhu akbar, Allāhu akbar.
>
> Allah is the Greatest, Allah is the Greatest, Allah is the Greatest.

Then:

> لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ
>
> Lā ilāha illAllāh wahdahu lā shareekalah, lahul mulk, wa lahul-hamd, yuhyee wa yumeet—wa huwa ''ala kulli shay''in qadeer. Lā ilāha illAllāh wahdahu lā shareekalah, anjaza wa''dahu, wa nasara ''abdahu, wa hazamal ahzāba wahdah.
>
> There is none worthy of worship except Allāh alone, without partner. To Him belongs all sovereignty and all praise. He alone gives life and death—and He is All-Powerful over everything. There is none worthy of worship except Allāh alone, without partner. He has fulfilled His promise, aided His servant, He alone has defeated the confederates.',
    'عند الصفا',
    NULL,
    true,
    13
  ),
  (
    'umrah',
    'Between the Green Lights',
    '{"subtitle": "Men: run · Women: walk normally", "desc": "Upon encountering the green lights between the two hills, **men only** should run from one green light to the next. Women should continue walking normally. This symbolizes the striving of Hajar (may Allah be pleased with her).\n\n**Tip:** Maintain your dhikr or du''a during this portion as well, remembering the story of Prophet Ibrahim''s wife Hajar and her faith in Allah''s plan.", "arabic": "بين العلمين الأخضرين"}',
    'Men: run · Women: walk normally',
    'Upon encountering the green lights between the two hills, **men only** should run from one green light to the next. Women should continue walking normally. This symbolizes the striving of Hajar (may Allah be pleased with her).

**Tip:** Maintain your dhikr or du''a during this portion as well, remembering the story of Prophet Ibrahim''s wife Hajar and her faith in Allah''s plan.',
    'بين العلمين الأخضرين',
    NULL,
    true,
    14
  ),
  (
    'umrah',
    'Shaving or Cutting Hair',
    '{"subtitle": "Fard · Men: shave or trim · Women: one inch", "desc": "Completing Umrah requires ending the Ihram state by removing your hair.\n\n**For Men**\n\nShaving the head is highly recommended (Sunnah), but trimming is also allowed. The Prophet ﷺ prayed for forgiveness three times for those who shave their heads, highlighting its greater reward. Shaving is considered more virtuous as an act of humility before Allah, symbolizing a fresh start and spiritual renewal.\n\n**For Women**\n\nTrim a small portion (approximately one inch) of hair from the end.\n\nWith this, the Umrah is complete, and you may exit the state of Ihram and resume everyday activities.", "arabic": "الحلق أو التقصير"}',
    'Fard · Men: shave or trim · Women: one inch',
    'Completing Umrah requires ending the Ihram state by removing your hair.

**For Men**

Shaving the head is highly recommended (Sunnah), but trimming is also allowed. The Prophet ﷺ prayed for forgiveness three times for those who shave their heads, highlighting its greater reward. Shaving is considered more virtuous as an act of humility before Allah, symbolizing a fresh start and spiritual renewal.

**For Women**

Trim a small portion (approximately one inch) of hair from the end.

With this, the Umrah is complete, and you may exit the state of Ihram and resume everyday activities.',
    'الحلق أو التقصير',
    NULL,
    true,
    15
  ),
  (
    'umrah',
    'Your Umrah is Complete – Mubarak!',
    '{"subtitle": "May Allah accept your Umrah (Ameen)", "desc": "**Taqabbal Allahu minna wa minkum**\n\nMay Allah accept your Umrah and may He answer all your Duas (ameen). Please also pray for us at the Qur''an Project – that Allah accepts our work and blesses us with Jannah tul Firdaus without reckoning (ameen).", "arabic": "تقبَّل الله عمرتك"}',
    'May Allah accept your Umrah (Ameen)',
    '**Taqabbal Allahu minna wa minkum**

May Allah accept your Umrah and may He answer all your Duas (ameen). Please also pray for us at the Qur''an Project – that Allah accepts our work and blesses us with Jannah tul Firdaus without reckoning (ameen).',
    'تقبَّل الله عمرتك',
    NULL,
    true,
    16
  ),
  (
    'hajj',
    'Before Assuming Ihram',
    '{"subtitle": "Ghusl · Niyyah · Settle your affairs", "desc": "You are a guest of Allah (swt) for Hajj — the fifth pillar of Islam. Prepare yourself in the best possible way. Perform Ghusl, clip your nails and remove excess body hair before leaving home.\n\n- Make sincere intention (niyyah) to perform Hajj solely for Allah''s pleasure\n- Settle all debts and resolve any outstanding disputes\n- Seek forgiveness from those you may have wronged\n- Write a will before traveling\n- Learn the rites of Hajj before departing", "arabic": "الإحرام"}',
    'Ghusl · Niyyah · Settle your affairs',
    'You are a guest of Allah (swt) for Hajj — the fifth pillar of Islam. Prepare yourself in the best possible way. Perform Ghusl, clip your nails and remove excess body hair before leaving home.

- Make sincere intention (niyyah) to perform Hajj solely for Allah''s pleasure
- Settle all debts and resolve any outstanding disputes
- Seek forgiveness from those you may have wronged
- Write a will before traveling
- Learn the rites of Hajj before departing',
    'الإحرام',
    NULL,
    true,
    1
  ),
  (
    'hajj',
    'Change into Your Ihram',
    '{"subtitle": "Men: two white cloths · Women: modest dress", "desc": "**Men**\n\nTwo white unstitched sheets — izar (lower) and rida (upper). No head coverings, no stitched garments. Slippers must not cover the ankle.\n\n**Women**\n\nUsual modest clothing. Must not wear gloves or cover the face (except in front of non-Mahram men if they normally wear niqab).\n\nChange before crossing the Miqat. If flying, change before departure or during a stopover.", "arabic": "لباس الإحرام"}',
    'Men: two white cloths · Women: modest dress',
    '**Men**

Two white unstitched sheets — izar (lower) and rida (upper). No head coverings, no stitched garments. Slippers must not cover the ankle.

**Women**

Usual modest clothing. Must not wear gloves or cover the face (except in front of non-Mahram men if they normally wear niqab).

Change before crossing the Miqat. If flying, change before departure or during a stopover.',
    'لباس الإحرام',
    NULL,
    true,
    2
  ),
  (
    'hajj',
    'Make Intention & Recite Talbiyah',
    '{"subtitle": "At the Miqat · Recite loudly until Day of Eid", "desc": "At the Miqat, make your intention for the type of Hajj you are performing (most common: Hajj al-Tamattu), then recite the Talbiyah:\n\n> لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ\n>\n> Labbayka Allahumma labbayka…\n>\n> At your service, Allah — all praise, favour and sovereignty are Yours.\n\nContinue reciting Talbiyah frequently until you stone Jamarat al-Aqabah on the 10th of Dhul Hijjah. (Sahih Muslim 1184)", "arabic": "النية والتلبية"}',
    'At the Miqat · Recite loudly until Day of Eid',
    'At the Miqat, make your intention for the type of Hajj you are performing (most common: Hajj al-Tamattu), then recite the Talbiyah:

> لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ
>
> Labbayka Allahumma labbayka…
>
> At your service, Allah — all praise, favour and sovereignty are Yours.

Continue reciting Talbiyah frequently until you stone Jamarat al-Aqabah on the 10th of Dhul Hijjah. (Sahih Muslim 1184)',
    'النية والتلبية',
    NULL,
    true,
    3
  ),
  (
    'hajj',
    '8th Dhul Hijjah — Arrive in Mina',
    '{"subtitle": "Spend the night in Mina · 5 prayers", "desc": "On the 8th of Dhul Hijjah (Yawm al-Tarwiyah), make your way to Mina and spend the day and night there.\n\n- Pray Dhuhr, Asr, Maghrib, Isha and Fajr in Mina — shortening prayers to 2 rak''ahs (Qasr)\n- Spend the night in your tent. Reflect, make du''a, and prepare your heart for the Day of Arafat.", "arabic": "يوم التروية — منى"}',
    'Spend the night in Mina · 5 prayers',
    'On the 8th of Dhul Hijjah (Yawm al-Tarwiyah), make your way to Mina and spend the day and night there.

- Pray Dhuhr, Asr, Maghrib, Isha and Fajr in Mina — shortening prayers to 2 rak''ahs (Qasr)
- Spend the night in your tent. Reflect, make du''a, and prepare your heart for the Day of Arafat.',
    'يوم التروية — منى',
    NULL,
    true,
    4
  ),
  (
    'hajj',
    '9th Dhul Hijjah — Stand at Arafat',
    '{"subtitle": "The pinnacle of Hajj · Du''a from Dhuhr to sunset", "desc": "> \"Hajj is Arafat.\" (Abu Dawud 1949)\n>\n> — The Prophet Muhammad ﷺ\n\nStand at Arafat from after Dhuhr until sunset. This is the most important act of Hajj — make abundant du''a, dhikr, and seek Allah''s forgiveness.\n\nThe best du''a is: **Lā ilāha illallāhu wahdahu lā sharīka lah, lahul-mulku wa lahul-hamdu wa huwa ''alā kulli shay''in qadīr.**", "arabic": "يوم عرفة"}',
    'The pinnacle of Hajj · Du''a from Dhuhr to sunset',
    '> "Hajj is Arafat." (Abu Dawud 1949)
>
> — The Prophet Muhammad ﷺ

Stand at Arafat from after Dhuhr until sunset. This is the most important act of Hajj — make abundant du''a, dhikr, and seek Allah''s forgiveness.

The best du''a is: **Lā ilāha illallāhu wahdahu lā sharīka lah, lahul-mulku wa lahul-hamdu wa huwa ''alā kulli shay''in qadīr.**',
    'يوم عرفة',
    NULL,
    true,
    5
  ),
  (
    'hajj',
    'Night in Muzdalifah',
    '{"subtitle": "Collect pebbles · Pray Maghrib & Isha", "desc": "After sunset on the 9th, depart Arafat for Muzdalifah. Combine and shorten Maghrib (3) and Isha (2) prayers upon arrival.\n\n- Collect 49 or 70 small pebbles (the size of a chickpea) for the stoning of Jamarat.\n- Spend the night under the open sky at Muzdalifah — this is Sunnah.\n- Pray Fajr here. Depart for Mina after Fajr (or in the last portion of the night for the elderly/weak).", "arabic": "المزدلفة"}',
    'Collect pebbles · Pray Maghrib & Isha',
    'After sunset on the 9th, depart Arafat for Muzdalifah. Combine and shorten Maghrib (3) and Isha (2) prayers upon arrival.

- Collect 49 or 70 small pebbles (the size of a chickpea) for the stoning of Jamarat.
- Spend the night under the open sky at Muzdalifah — this is Sunnah.
- Pray Fajr here. Depart for Mina after Fajr (or in the last portion of the night for the elderly/weak).',
    'المزدلفة',
    NULL,
    true,
    6
  ),
  (
    'hajj',
    '10th Dhul Hijjah — Rami al-Jamarat',
    '{"subtitle": "Stone Jamarat al-Aqabah · 7 pebbles", "desc": "Return to Mina and stone Jamarat al-Aqabah (the large pillar) with 7 pebbles. Say **Bismillah, Allahu Akbar** with each throw.\n\n> بِسْمِ اللهِ اللهُ أَكْبَرُ\n>\n> Recite with each of the 7 pebbles\n\nAfter stoning, the Talbiyah stops. Next: sacrifice, shave/cut hair, and change out of Ihram.", "arabic": "رمي الجمرات"}',
    'Stone Jamarat al-Aqabah · 7 pebbles',
    'Return to Mina and stone Jamarat al-Aqabah (the large pillar) with 7 pebbles. Say **Bismillah, Allahu Akbar** with each throw.

> بِسْمِ اللهِ اللهُ أَكْبَرُ
>
> Recite with each of the 7 pebbles

After stoning, the Talbiyah stops. Next: sacrifice, shave/cut hair, and change out of Ihram.',
    'رمي الجمرات',
    NULL,
    true,
    7
  ),
  (
    'hajj',
    'Sacrifice & Exit Ihram',
    '{"subtitle": "Qurbani · Shave or cut hair · Change clothes", "desc": "On the Day of Eid (10th Dhul Hijjah), after stoning Jamarat al-Aqabah:\n\n1. **Sacrifice (Hady)** — Offer your sacrificial animal (or arrange through an authorised agent).\n2. **Shave or cut hair (Halq/Taqsir)** — Men should ideally shave the head completely. Women cut a fingertip''s length from their hair.\n3. **Change out of Ihram** — After shaving, you may change into regular clothing. Most restrictions of Ihram are now lifted.", "arabic": "الهدي والتحلل"}',
    'Qurbani · Shave or cut hair · Change clothes',
    'On the Day of Eid (10th Dhul Hijjah), after stoning Jamarat al-Aqabah:

1. **Sacrifice (Hady)** — Offer your sacrificial animal (or arrange through an authorised agent).
2. **Shave or cut hair (Halq/Taqsir)** — Men should ideally shave the head completely. Women cut a fingertip''s length from their hair.
3. **Change out of Ihram** — After shaving, you may change into regular clothing. Most restrictions of Ihram are now lifted.',
    'الهدي والتحلل',
    NULL,
    true,
    8
  ),
  (
    'hajj',
    'Tawaf al-Ifadah & Sa''i',
    '{"subtitle": "7 circuits of the Kaaba · 7 rounds of Sa''i", "desc": "Return to Makkah and perform Tawaf al-Ifadah — 7 circuits around the Kaaba. This is a pillar of Hajj; without it, Hajj is incomplete.\n\n**After Tawaf**\n\nPray 2 rak''ahs behind Maqam Ibrahim, drink Zamzam water, then perform Sa''i — walking 7 times between Safa and Marwah.\n\nAfter completing Sa''i, all restrictions of Ihram are fully lifted — Hajj is essentially complete.", "arabic": "طواف الإفاضة والسعي"}',
    '7 circuits of the Kaaba · 7 rounds of Sa''i',
    'Return to Makkah and perform Tawaf al-Ifadah — 7 circuits around the Kaaba. This is a pillar of Hajj; without it, Hajj is incomplete.

**After Tawaf**

Pray 2 rak''ahs behind Maqam Ibrahim, drink Zamzam water, then perform Sa''i — walking 7 times between Safa and Marwah.

After completing Sa''i, all restrictions of Ihram are fully lifted — Hajj is essentially complete.',
    'طواف الإفاضة والسعي',
    NULL,
    true,
    9
  ),
  (
    'hajj',
    'Days of Tashreeq & Farewell Tawaf',
    '{"subtitle": "11th–13th: stone all 3 Jamarat · Tawaf al-Wida", "desc": "**Days of Tashreeq (11th–13th Dhul Hijjah)**\n\nStone all three Jamarat (small, medium, large) — 7 pebbles each — after midday on each day. You may depart on the 12th if you leave before sunset (Rukhsah).\n\n**Tawaf al-Wida (Farewell Tawaf)**\n\nThe last act before leaving Makkah. Perform 7 circuits around the Kaaba. Make du''a and bid farewell to the Sacred Mosque with a heavy heart and tears of gratitude.\n\nMay Allah accept your Hajj and make it a Hajj Mabrur — a pilgrimage accepted by Allah.", "arabic": "أيام التشريق وطواف الوداع"}',
    '11th–13th: stone all 3 Jamarat · Tawaf al-Wida',
    '**Days of Tashreeq (11th–13th Dhul Hijjah)**

Stone all three Jamarat (small, medium, large) — 7 pebbles each — after midday on each day. You may depart on the 12th if you leave before sunset (Rukhsah).

**Tawaf al-Wida (Farewell Tawaf)**

The last act before leaving Makkah. Perform 7 circuits around the Kaaba. Make du''a and bid farewell to the Sacred Mosque with a heavy heart and tears of gratitude.

May Allah accept your Hajj and make it a Hajj Mabrur — a pilgrimage accepted by Allah.',
    'أيام التشريق وطواف الوداع',
    NULL,
    true,
    10
  );

-- Hub ayah (keep existing eyebrow/title/disclaimer).
INSERT INTO public.app_settings (key, value, description)
VALUES (
  'pilgrimage_hub',
  '{"eyebrow":"Seeking the Pleasure of Allah","title":"Umrah & Hajj Guide","disclaimer":"All guides are based on authentic scholarly sources. Always consult a qualified scholar for personal rulings.","ayah_ar":"وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ","ayah_en":"Complete the Hajj and Umrah for Allah","ayah_ref":"2:196"}'::jsonb,
  'Umrah & Hajj hub hero and disclaimer copy'
)
ON CONFLICT (key) DO UPDATE SET
  value = public.app_settings.value || '{"ayah_ar":"وَأَتِمُّوا الْحَجَّ وَالْعُمْرَةَ لِلَّهِ","ayah_en":"Complete the Hajj and Umrah for Allah","ayah_ref":"2:196"}'::jsonb,
  updated_at = now();

INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order)
VALUES
  (
    'umrah',
    'ihram_before',
    'Step 1 · Before Assuming Ihram',
    'Ghusl · Niyyah · Settle your affairs',
    'image',
    NULL,
    1
  ),
  (
    'umrah',
    'ihram_change',
    'Step 2 · Change into Your Ihram',
    'Men: two white cloths · Women: modest dress',
    'image',
    NULL,
    2
  ),
  (
    'umrah',
    'intention',
    'Step 3 · Make the Intention for Umrah',
    'Miqat is 20–30 min before landing',
    'image',
    NULL,
    3
  ),
  (
    'umrah',
    'talbiyah',
    'Step 4 · Recite the Talbiyah',
    'Men: loud · Women: softly · Until Tawaf',
    'image',
    NULL,
    4
  ),
  (
    'umrah',
    'haram',
    'Step 5 · Entering Masjid Al-Haram',
    'Enter with right foot · Recite du''a',
    'image',
    NULL,
    5
  ),
  (
    'umrah',
    'tawaf_prep',
    'Step 6 · Performing Tawaf',
    'State of Wudu · Men: Iztiba''',
    'image',
    NULL,
    6
  ),
  (
    'umrah',
    'tawaf_start',
    'Step 7 · Start Tawaf',
    'Black Stone · Bismillah Allahu Akbar · 7 circuits',
    'image',
    NULL,
    7
  ),
  (
    'umrah',
    'yemeni',
    'Step 8 · Yemeni Corner',
    'Recite Rabbana ātina each time you pass',
    'image',
    NULL,
    8
  ),
  (
    'umrah',
    'circuits',
    'Step 9 · Complete 7 Circuits',
    'Count from first complete circuit',
    'image',
    NULL,
    9
  ),
  (
    'umrah',
    'after_tawaf',
    'Step 10 · After Tawaf',
    'Maqam Ibrahim · 2 Rak''ahs',
    'image',
    NULL,
    10
  ),
  (
    'umrah',
    'zamzam',
    'Step 11 · Drink Zamzam',
    'Make du''a · Pour over your head',
    'image',
    NULL,
    11
  ),
  (
    'umrah',
    'safa',
    'Step 12 · Make Your Way to Mount Safa',
    'Recite the verse of Safa & Marwah',
    'image',
    NULL,
    12
  ),
  (
    'umrah',
    'safa_reach',
    'Step 13 · Upon Reaching Safa',
    'Face Ka''bah · Allahu Akbar · Lā ilāha illAllāh',
    'image',
    NULL,
    13
  ),
  (
    'umrah',
    'green_lights',
    'Step 14 · Between the Green Lights',
    'Men: run · Women: walk normally',
    'image',
    NULL,
    14
  ),
  (
    'umrah',
    'shaving',
    'Step 15 · Shaving or Cutting Hair',
    'Fard · Men: shave or trim · Women: one inch',
    'image',
    NULL,
    15
  ),
  (
    'umrah',
    'complete',
    'Step 16 · Your Umrah is Complete – Mubarak!',
    'May Allah accept your Umrah (Ameen)',
    'image',
    NULL,
    16
  ),
  (
    'hajj',
    'ihram_before',
    'Step 1 · Before Assuming Ihram',
    'Ghusl · Niyyah · Settle your affairs',
    'image',
    NULL,
    1
  ),
  (
    'hajj',
    'ihram_change',
    'Step 2 · Change into Your Ihram',
    'Men: two white cloths · Women: modest dress',
    'image',
    NULL,
    2
  ),
  (
    'hajj',
    'intention',
    'Step 3 · Make Intention & Recite Talbiyah',
    'At the Miqat · Recite loudly until Day of Eid',
    'image',
    NULL,
    3
  ),
  (
    'hajj',
    'mina',
    'Step 4 · 8th Dhul Hijjah — Arrive in Mina',
    'Spend the night in Mina · 5 prayers',
    'image',
    NULL,
    4
  ),
  (
    'hajj',
    'arafat',
    'Step 5 · 9th Dhul Hijjah — Stand at Arafat',
    'The pinnacle of Hajj · Du''a from Dhuhr to sunset',
    'image',
    NULL,
    5
  ),
  (
    'hajj',
    'muzdalifah',
    'Step 6 · Night in Muzdalifah',
    'Collect pebbles · Pray Maghrib & Isha',
    'image',
    NULL,
    6
  ),
  (
    'hajj',
    'rami',
    'Step 7 · 10th Dhul Hijjah — Rami al-Jamarat',
    'Stone Jamarat al-Aqabah · 7 pebbles',
    'image',
    NULL,
    7
  ),
  (
    'hajj',
    'sacrifice',
    'Step 8 · Sacrifice & Exit Ihram',
    'Qurbani · Shave or cut hair · Change clothes',
    'image',
    NULL,
    8
  ),
  (
    'hajj',
    'ifadah',
    'Step 9 · Tawaf al-Ifadah & Sa''i',
    '7 circuits of the Kaaba · 7 rounds of Sa''i',
    'image',
    NULL,
    9
  ),
  (
    'hajj',
    'tashreeq',
    'Step 10 · Days of Tashreeq & Farewell Tawaf',
    '11th–13th: stone all 3 Jamarat · Tawaf al-Wida',
    'image',
    NULL,
    10
  )
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
