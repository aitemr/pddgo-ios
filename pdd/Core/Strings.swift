//
//  Strings.swift
//  pdd
//
//  UI strings. Russian is the source-of-truth; kk/en are served at runtime via
//  Localizer.pick(ru:kk:en:) based on Session.shared.language (falls back to ru).
//

import Foundation

enum L {
    // Nav
    static var navTests: String   { Localizer.pick(ru: "Тесты",   kk: "Тесттер", en: "Tests") }
    static var navAkzhol: String  { Localizer.pick(ru: "Акжол",   kk: "Ақжол",   en: "Akzhol") }
    static var navProfile: String { Localizer.pick(ru: "Профиль", kk: "Профиль", en: "Profile") }

    // Tests
    static var testMainTitle: String { Localizer.pick(ru: "Пробное\nтестирование\nПДД РК", kk: "ПДД РК\nсынақ\nтестілеуі", en: "PDD RK\nmock\ntest") }
    static var testStartTrialBtn: String { Localizer.pick(ru: "Начать пробное тестирование", kk: "Сынақ тестілеуді бастау", en: "Start mock test") }
    static var testPageTitle: String { Localizer.pick(ru: "Пробное тестирование ПДД РК", kk: "ПДД РК сынақ тестілеуі", en: "PDD RK mock test") }
    static var testPageTitleIndividual: String { Localizer.pick(ru: "Индивидуальное тестирование", kk: "Жеке тестілеу", en: "Individual test") }
    static var testDescriptionMain: String { Localizer.pick(
        ru: "Это тренировочный экзамен, составленный на основе актуальных правил дорожного движения Республики Казахстан. Тест помогает проверить уровень знаний, выявить ошибки и подготовиться к реальной сдаче теоретического экзамена в спецЦОНе. Подходит как для начинающих водителей, так и для тех, кто хочет освежить знания. Наш пробный тест полностью соответствует действующим ПДД РК и формату экзамена. После прохождения ты увидишь свои ошибки и поймёшь, что нужно подтянуть. Проходи сколько угодно — это бесплатно и без ограничений",
        kk: "Бұл Қазақстан Республикасының қолданыстағы жол қозғалысы ережелері негізінде жасалған жаттығу емтиханы. Тест білім деңгейіңді тексеруге, қателерді анықтауға және спецХҚКО-дағы нақты теориялық емтиханға дайындалуға көмектеседі. Бастаушы жүргізушілерге де, білімін жаңартқысы келетіндерге де қолайлы. Сынақ тестіміз қолданыстағы ПДД РК мен емтихан форматына толық сәйкес келеді. Өткеннен кейін қателеріңді көріп, нені пысықтау керектігін түсінесің. Қалағаныңша өт — бұл тегін әрі шектеусіз",
        en: "This is a practice exam built on the current road traffic rules of the Republic of Kazakhstan. It helps you check your knowledge, spot mistakes, and get ready for the real theory exam at the testing center. Suitable both for new drivers and for those refreshing their knowledge. Our mock test fully matches the current PDD RK and the exam format. After finishing, you'll see your mistakes and know what to work on. Take it as many times as you like — it's free and unlimited") }
    static var testDescriptionIndividual: String { Localizer.pick(
        ru: "Хочешь сдать ПДД без второго шанса?\nНачни с умной подготовки. Этот тест адаптирован под тебя: он не тратит время на то, что ты уже знаешь, и бьёт точно по ошибкам.",
        kk: "ПДД-ны екінші мүмкіндіксіз тапсырғың келе ме?\nАқылды дайындықтан баста. Бұл тест саған бейімделген: сен білетін нәрсеге уақыт жұмсамайды, тура қателерге бағытталады.",
        en: "Want to pass the exam on the first try?\nStart with smart prep. This test adapts to you: it doesn't waste time on what you already know and targets your mistakes precisely.") }
    static var workOnMistakes: String { Localizer.pick(ru: "Провести работу над ошибками с Акжол", kk: "Ақжолмен қателер бойынша жұмыс жүргізу", en: "Work on your mistakes with Akzhol") }
    static var workOnMistakesShort: String { Localizer.pick(ru: "Работа над ошибками", kk: "Қателермен жұмыс", en: "Work on mistakes") }
    static var individualTestingAiDesc: String { Localizer.pick(
        ru: "ИИ-ассистент специально подготовил для тебя тест, основанный на твоих ошибках и темах, где ты чаще всего допускаешь неточности.",
        kk: "ЖИ-көмекші сенің қателеріңе және жиі қателесетін тақырыптарыңа негізделген тестті арнайы дайындады.",
        en: "The AI assistant has prepared a test based on your mistakes and the topics where you slip up most often.") }
    static var startTestingBtn: String { Localizer.pick(ru: "Начать тестирование", kk: "Тестілеуді бастау", en: "Start test") }
    static var recommended: String { Localizer.pick(ru: "Рекомендуем", kk: "Ұсынамыз", en: "Recommended") }
    static var trialTestingShort: String { Localizer.pick(ru: "Пробное тестирование", kk: "Сынақ тестілеу", en: "Mock test") }
    static var testHistoryTitle: String { Localizer.pick(ru: "История тестирований", kk: "Тестілеу тарихы", en: "Test history") }
    static var testHistorySubtitle: String { Localizer.pick(ru: "История сохраняется на устройстве. Ниже — последние 8 записей.", kk: "Тарих құрылғыда сақталады. Төменде — соңғы 8 жазба.", en: "History is stored on your device. Below are the last 8 entries.") }
    static var testHistoryShowAll: String { Localizer.pick(ru: "Все", kk: "Барлығы", en: "All") }
    static var testHistoryFullTitle: String { Localizer.pick(ru: "Вся история", kk: "Толық тарих", en: "Full history") }
    static var testHistoryEmpty: String { Localizer.pick(ru: "Здесь появятся записи после полного прохождения пробного теста", kk: "Сынақ тестін толық өткеннен кейін мұнда жазбалар пайда болады", en: "Entries appear here after you finish a full mock test") }
    static var testDetailAppBarTitle: String { Localizer.pick(ru: "Пробное тестирование", kk: "Сынақ тестілеу", en: "Mock test") }
    static var questionsCountLabel: String { Localizer.pick(ru: "Количество вопросов:", kk: "Сұрақтар саны:", en: "Number of questions:") }
    static var passRequirementLabel: String { Localizer.pick(ru: "Для успешной сдачи необходимо:", kk: "Сәтті тапсыру үшін қажет:", en: "To pass you need:") }
    static var mistakesEmptyStartHint: String { Localizer.pick(ru: "Пока в работе над ошибками нет вопросов. Сначала пройдите тест и допустите ошибки — они автоматически появятся здесь.", kk: "Әзірге қателермен жұмыста сұрақтар жоқ. Алдымен тест тапсырып, қателессеңіз — олар мұнда автоматты түрде пайда болады.", en: "No questions to review yet. Take a test and make some mistakes — they'll show up here automatically.") }

    static func testHistoryRowSubtitle(_ score: Int, _ total: Int, _ date: String) -> String {
        "\(score)/\(total) · \(date)"
    }

    // Road-sign detector promo
    static var roadsignDetector: String { Localizer.pick(ru: "Определитель\nдорожных знаков", kk: "Жол белгілерін\nанықтаушы", en: "Road sign\ndetector") }
    static var go: String { Localizer.pick(ru: "Перейти", kk: "Өту", en: "Go") }

    // Road-sign detector screen
    static var roadsignTitle: String        { Localizer.pick(ru: "Определитель знаков", kk: "Белгілерді анықтау", en: "Sign detector") }
    static var roadsignIntroTitle: String   { Localizer.pick(ru: "Сфотографируй\nили выбери знак", kk: "Белгіні суретке түсір\nнемесе таңда", en: "Snap or pick\na road sign") }
    static var roadsignIntroSubtitle: String { Localizer.pick(ru: "Акжол распознает знак и объяснит, что он означает", kk: "Ақжол белгіні таниды және мағынасын түсіндіреді", en: "Akzhol will recognize the sign and explain it") }
    static var roadsignCameraBtn: String    { Localizer.pick(ru: "Камера", kk: "Камера", en: "Camera") }
    static var roadsignGalleryBtn: String   { Localizer.pick(ru: "Галерея", kk: "Галерея", en: "Gallery") }
    static var roadsignPromptText: String   { Localizer.pick(ru: "Что это за дорожный знак? Объясни кратко и понятно.", kk: "Бұл қандай жол белгісі? Қысқа әрі түсінікті түсіндір.", en: "What road sign is this? Explain briefly and clearly.") }

    // Quiz
    static var quizCheck: String         { Localizer.pick(ru: "Проверить", kk: "Тексеру", en: "Check") }
    static var quizNext: String          { Localizer.pick(ru: "Далее",     kk: "Келесі",  en: "Next") }
    static var quizFinish: String        { Localizer.pick(ru: "Завершить", kk: "Аяқтау",  en: "Finish") }
    static var quizCorrectPrefix: String { Localizer.pick(ru: "Правильно: ", kk: "Дұрыс: ", en: "Correct: ") }
    static var askAkzhol: String         { Localizer.pick(ru: "Спросить Акжола", kk: "Ақжолдан сұрау", en: "Ask Akzhol") }
    static var aiDefaultQuestion: String { Localizer.pick(ru: "Почему мой ответ был неправильным?", kk: "Менің жауабым неге қате болды?", en: "Why was my answer wrong?") }
    static var quizReplayUnavailable: String { Localizer.pick(ru: "Не удалось открыть этот тест. Запись устарела или вопросы обновились.", kk: "Бұл тестті ашу мүмкін болмады. Жазба ескірген немесе сұрақтар жаңартылған.", en: "Couldn't open this test. The record is outdated or the questions have changed.") }

    // Results
    static var resultSuccessSubtitle: String { Localizer.pick(
        ru: "Отлично! Ты бы сдал экзамен 🎉\nПродолжай тренироваться,\nчтобы на реальной сдаче\nне было ни единого сомнения",
        kk: "Тамаша! Сен емтиханды тапсырар едің 🎉\nЖаттығуды жалғастыр,\nнақты тапсыруда\nкүмән болмауы үшін",
        en: "Great! You'd pass the exam 🎉\nKeep practicing so there's\nnot a single doubt\non the real test") }
    static var resultFailSubtitle: String { Localizer.pick(
        ru: "Этого балла недостаточно для\nуспешного прохождения теста",
        kk: "Бұл балл тестті сәтті\nөту үшін жеткіліксіз",
        en: "This score isn't enough\nto pass the test") }
    static var resultAkzholBubble: String { Localizer.pick(ru: "Акжол не готов вас пропустить дальше", kk: "Ақжол сізді әрі қарай жіберуге дайын емес", en: "Akzhol isn't ready to let you through") }
    static var resultNextTest: String { Localizer.pick(ru: "Перейди на следующий тест", kk: "Келесі тестке өту", en: "Go to the next test") }
    static var resultTryAgain: String { Localizer.pick(ru: "Попробовать еще", kk: "Қайта көру", en: "Try again") }
    static var completionTitle: String { Localizer.pick(ru: "Вы уже на шаг ближе\nк своим правам!", kk: "Сіз куәлігіңізге\nбір қадам жақынсыз!", en: "You're one step closer\nto your license!") }
    static var completionSubtitle: String { Localizer.pick(ru: "Продолжайте обучение и будьте готовы\nк успешной сдаче экзамена", kk: "Оқуды жалғастырыңыз және емтиханды\nсәтті тапсыруға дайын болыңыз", en: "Keep learning and be ready\nto pass the exam") }
    static var continueBtn: String { Localizer.pick(ru: "Продолжить", kk: "Жалғастыру", en: "Continue") }

    // Streak
    static var streakTitle: String     { Localizer.pick(ru: "Серия", kk: "Серия", en: "Streak") }
    static var streakBest: String      { Localizer.pick(ru: "Рекорд", kk: "Рекорд", en: "Best") }
    static var streakEmptyHint: String { Localizer.pick(ru: "Начни сегодня!", kk: "Бүгін баста!", en: "Start today!") }
    static var streakKeepGoing: String { Localizer.pick(ru: "Так держать!", kk: "Осылай жалғастыр!", en: "Keep it up!") }
    static func streakDays(_ n: Int) -> String {
        Localizer.pick(ru: "\(n) дн. подряд", kk: "\(n) күн қатарынан", en: n == 1 ? "1 day in a row" : "\(n) days in a row")
    }
    static var streakWeekDays: [String] {
        Localizer.pick(ru: "ПН,ВТ,СР,ЧТ,ПТ,СБ,ВС", kk: "ДС,СС,СР,БС,ЖМ,СН,ЖС", en: "Mo,Tu,We,Th,Fr,Sa,Su")
            .split(separator: ",").map(String.init)
    }

    static func resultScore(_ s: Int, _ t: Int) -> String {
        Localizer.pick(ru: "\(s) из \(t)", kk: "\(s) / \(t)", en: "\(s) of \(t)")
    }

    // Akzhol AI
    static var akzholGreeting: String { Localizer.pick(ru: "Здравия желаю,\nменя зовут Акжол", kk: "Сәлеметсіз бе,\nменің атым Ақжол", en: "Greetings,\nmy name is Akzhol") }
    static var akzholCanHelp: String { Localizer.pick(ru: "Я могу вам помочь с:", kk: "Мен сізге көмектесе аламын:", en: "I can help you with:") }
    static var akzholName: String   { Localizer.pick(ru: "Акжол", kk: "Ақжол", en: "Akzhol") }
    static var akzholRole: String   { Localizer.pick(ru: "Сотрудник МВД РК", kk: "ҚР ІІМ қызметкері", en: "Officer, MIA RK") }
    static var chatInputHint: String { Localizer.pick(ru: "Напишите свой вопрос", kk: "Сұрағыңызды жазыңыз", en: "Type your question") }
    static var chatSend: String { Localizer.pick(ru: "Отправить", kk: "Жіберу", en: "Send") }
    static var navBack: String { Localizer.pick(ru: "Назад", kk: "Артқа", en: "Back") }
    static var chatAttachPhoto: String { Localizer.pick(ru: "Прикрепить фото", kk: "Сурет тіркеу", en: "Attach photo") }
    static var chatRemovePhoto: String { Localizer.pick(ru: "Удалить фото", kk: "Суретті жою", en: "Remove photo") }
    static var akzholCard1Title: String { Localizer.pick(ru: "С решением вопросов\nпо ПДД РК", kk: "ПДД РК бойынша\nмәселелерді шешуде", en: "Resolving questions\nabout PDD RK") }
    static var akzholCard1Subtitle: String { Localizer.pick(
        ru: "Оформление ДТП, спорные ситуации и\nвзаимодействие с органами — быстро,\nпрофессионально и в рамках закона",
        kk: "ЖКО рәсімдеу, даулы жағдайлар және\nоргандармен өзара әрекет — жылдам,\nкәсіби және заң аясында",
        en: "Filing accident reports, disputes and\ndealing with authorities — fast,\nprofessional and within the law") }
    static var akzholCard2Title: String { Localizer.pick(ru: "Помогу тебе с\nэкзаменационными\nвопросами ПДД", kk: "ПДД емтихан\nсұрақтарымен\nкөмектесемін", en: "I'll help you with\nthe PDD exam\nquestions") }
    static var akzholCard2Subtitle: String { Localizer.pick(
        ru: "Разбираем спорные формулировки,\nобновлённые требования и реальные\nдорожные ситуации",
        kk: "Даулы тұжырымдарды, жаңартылған\nталаптарды және нақты жол\nжағдайларын талдаймыз",
        en: "We break down tricky wording,\nupdated requirements and real\nroad situations") }
    static var akzholCard3Title: String { Localizer.pick(ru: "Отвечу на любые твои\nвопросы по вождению", kk: "Көлік жүргізу бойынша кез келген\nсұрағыңа жауап беремін", en: "I'll answer any of your\ndriving questions") }
    static var akzholCard3Subtitle: String { Localizer.pick(
        ru: "От теории ПДД до реальных ситуаций\nна дороге. Объясняю понятно, без\nзанудства и лишних терминов",
        kk: "ПДД теориясынан нақты жол\nжағдайларына дейін. Түсінікті,\nартық терминсіз түсіндіремін",
        en: "From PDD theory to real road\nsituations. I explain clearly, without\nfluff or jargon") }
    static var freemiumAkzholLimitTitle: String { Localizer.pick(ru: "Лимит Акжола", kk: "Ақжол лимиті", en: "Akzhol limit") }
    static var freemiumAkzholLimitBody: String { Localizer.pick(ru: "Бесплатно доступны 3 ответа Акжола. Оформите Premium, чтобы общаться без ограничений.", kk: "Тегін Ақжолдың 3 жауабы қолжетімді. Шектеусіз сөйлесу үшін Premium рәсімдеңіз.", en: "You get 3 free Akzhol replies. Get Premium to chat without limits.") }
    static var freemiumOpenPremium: String { Localizer.pick(ru: "Оформить Premium", kk: "Premium рәсімдеу", en: "Get Premium") }

    // Profile
    static var profileDemoUserName: String   { Localizer.pick(ru: "Гость", kk: "Қонақ", en: "Guest") }
    static var licenseCatB: String           { Localizer.pick(ru: "Категория B", kk: "B санаты", en: "Category B") }
    static var profileLevelTitle: String     { Localizer.pick(ru: "Прогресс", kk: "Прогресс", en: "Progress") }
    static var profileLevelLearner: String   { Localizer.pick(ru: "Ученик", kk: "Үйренуші", en: "Learner") }
    static var profileLevelDriver: String    { Localizer.pick(ru: "Водитель", kk: "Жүргізуші", en: "Driver") }
    static var profileLevelExpert: String    { Localizer.pick(ru: "Эксперт", kk: "Сарапшы", en: "Expert") }
    static var profileNotifications: String  { Localizer.pick(ru: "Уведомления", kk: "Хабарландырулар", en: "Notifications") }
    static var profileHaptics: String        { Localizer.pick(ru: "Вибрация", kk: "Дірілдеу", en: "Haptics") }
    static var profileSound: String          { Localizer.pick(ru: "Звуки", kk: "Дыбыстар", en: "Sounds") }
    static var favoritesTitle: String        { Localizer.pick(ru: "Избранное", kk: "Таңдаулылар", en: "Favorites") }
    static var editProfile: String           { Localizer.pick(ru: "Редактировать профиль", kk: "Профильді өзгерту", en: "Edit Profile") }
    static var selectLanguage: String        { Localizer.pick(ru: "Язык", kk: "Тіл", en: "Language") }
    static var privacyPolicy: String         { Localizer.pick(ru: "Политика конфиденциальности", kk: "Құпиялылық саясаты", en: "Privacy Policy") }
    static var termsOfUse: String            { Localizer.pick(ru: "Условия использования", kk: "Қолдану шарттары", en: "Terms of Use") }
    static var animationsToggle: String      { Localizer.pick(ru: "Анимации", kk: "Анимациялар", en: "Animations") }
    static var rateApp: String               { Localizer.pick(ru: "Оценить приложение", kk: "Қолданбаға баға беру", en: "Rate the App") }
    static var shareApp: String              { Localizer.pick(ru: "Поделиться приложением", kk: "Қолданбамен бөлісу", en: "Share the App") }
    static var deleteAccount: String         { Localizer.pick(ru: "Удалить аккаунт", kk: "Аккаунтты жою", en: "Delete Account") }
    static var logoutTitle: String           { Localizer.pick(ru: "Выйти из аккаунта", kk: "Аккаунттан шығу", en: "Log Out") }
    static var logoutConfirmTitle: String    { Localizer.pick(ru: "Выйти из аккаунта?", kk: "Аккаунттан шығасыз ба?", en: "Log out?") }
    static var logoutConfirmMessage: String  { Localizer.pick(ru: "Вы выйдете из профиля и вернётесь на экран приветствия.", kk: "Профильден шығып, сәлемдесу экранына ораласыз.", en: "You'll be signed out and returned to the welcome screen.") }
    static var logoutConfirmButton: String   { Localizer.pick(ru: "Выйти", kk: "Шығу", en: "Log Out") }
    static var cancel: String                { Localizer.pick(ru: "Отмена", kk: "Болдырмау", en: "Cancel") }
    static var supportTitle: String          { Localizer.pick(ru: "Служба поддержки", kk: "Қолдау қызметі", en: "Support") }
    static var supportSubtitle: String       { Localizer.pick(ru: "Поможем если столкнетесь с проблемой", kk: "Мәселе туындаса көмектесеміз", en: "We're here if you run into a problem") }
    static var premium: String               { Localizer.pick(ru: "Premium", en: "Premium") }
    static var langSelectionTitle: String    { Localizer.pick(ru: "Выбор языка", kk: "Тіл таңдау", en: "Choose language") }

    static func profileCorrectAnswersProgress(_ done: Int, _ total: Int) -> String {
        Localizer.pick(ru: "Правильных ответов: \(done) из \(total)", kk: "Дұрыс жауаптар: \(done) / \(total)", en: "Correct answers: \(done) of \(total)")
    }

    // Paywall
    static var paywallHeroPrefix: String { Localizer.pick(ru: "Начни с ", kk: "Бастаңыз: ", en: "Start with ") }
    static var paywallHeroHighlight: String { Localizer.pick(ru: "3 дней бесплатно", kk: "3 күн тегін", en: "3 days free") }
    static var paywallSubtitle: String { Localizer.pick(ru: "Видеоуроки, все тесты, ИИ-помощник\nАкжол — без ограничений", kk: "Бейнесабақтар, барлық тесттер, ЖИ-көмекші\nАқжол — шектеусіз", en: "Video lessons, all tests, AI assistant\nAkzhol — no limits") }
    static var paywallFeatureVideos: String { Localizer.pick(ru: "Все видеоуроки без ограничений", kk: "Барлық бейнесабақтар шектеусіз", en: "All video lessons, unlimited") }
    static var paywallFeatureTests: String { Localizer.pick(ru: "Полный банк тестовых вопросов", kk: "Тест сұрақтарының толық банкі", en: "Full bank of test questions") }
    static var paywallFeatureAkzhol: String { Localizer.pick(ru: "Неограниченные чаты с Акжолом", kk: "Ақжолмен шектеусіз чаттар", en: "Unlimited chats with Akzhol") }
    static var paywallFeatureMistakes: String { Localizer.pick(ru: "Персональный анализ ошибок", kk: "Қателерді жеке талдау", en: "Personal mistake analysis") }
    static var paywallPlanWeekly: String { Localizer.pick(ru: "Неделя", kk: "Апта", en: "Week") }
    static var paywallPlanMonthly: String { Localizer.pick(ru: "Месяц", kk: "Ай", en: "Month") }
    static let paywallPriceWeekly = "990 ₸"
    static let paywallPriceMonthly = "2 490 ₸"
    static var paywallPeriodWeekly: String { Localizer.pick(ru: "в неделю", kk: "аптасына", en: "per week") }
    static var paywallPeriodMonthly: String { Localizer.pick(ru: "в месяц", kk: "айына", en: "per month") }
    static var paywallPerDayWeekly: String { Localizer.pick(ru: "141 ₸/день", kk: "141 ₸/күн", en: "141 ₸/day") }
    static var paywallPerDayMonthly: String { Localizer.pick(ru: "83 ₸/день", kk: "83 ₸/күн", en: "83 ₸/day") }
    static var paywallBadgeBestDeal: String { Localizer.pick(ru: "Лучшее предложение", kk: "Ең тиімді ұсыныс", en: "Best deal") }
    static var paywallCancelAnytime: String { Localizer.pick(ru: "Отмена в любое время", kk: "Кез келген уақытта тоқтату", en: "Cancel anytime") }
    static var paywallDisclaimerAfterTrial: String { Localizer.pick(ru: "После пробного периода спишется стоимость\nвыбранного плана. Подписка автопродляется.", kk: "Сынақ кезеңінен кейін таңдалған жоспардың\nқұны алынады. Жазылым автоматты түрде ұзартылады.", en: "After the trial, the selected plan's price will be\ncharged. The subscription renews automatically.") }
    static var paywallRestorePurchases: String { Localizer.pick(ru: "Восстановить покупки", kk: "Сатып алуларды қалпына келтіру", en: "Restore purchases") }
    static func paywallCtaWithPrice(_ price: String) -> String {
        Localizer.pick(ru: "Продолжить за \(price)", kk: "\(price) үшін жалғастыру", en: "Continue for \(price)")
    }

    // Onboarding
    static var onboardingNext: String  { Localizer.pick(ru: "Далее", kk: "Келесі", en: "Next") }
    static var onboardingStart: String { Localizer.pick(ru: "Начать", kk: "Бастау", en: "Start") }
    // Survey
    static var surveyNext: String { Localizer.pick(ru: "Следующий вопрос", kk: "Келесі сұрақ", en: "Next question") }
    static var surveyFinish: String { Localizer.pick(ru: "Завершить", kk: "Аяқтау", en: "Finish") }
    static var surveyVehicleQuestion: String { Localizer.pick(ru: "На каком транспортном средстве ты планируешь передвигаться?", kk: "Қандай көлік құралымен жүруді жоспарлайсың?", en: "What vehicle do you plan to drive?") }
    static var surveyVehicleOptions: [(id: String, icon: String, title: String, subtitle: String)] {
        [
            ("car", "Car", Localizer.pick(ru: "Легковой автомобиль", kk: "Жеңіл автокөлік", en: "Car"), Localizer.pick(ru: "Категория B", kk: "B санаты", en: "Category B")),
            ("truck", "Truck", Localizer.pick(ru: "Грузовик", kk: "Жүк көлігі", en: "Truck"), Localizer.pick(ru: "Категория C, D", kk: "C, D санаты", en: "Category C, D")),
            ("bike", "Bike", Localizer.pick(ru: "Мотоцикл", kk: "Мотоцикл", en: "Motorcycle"), Localizer.pick(ru: "Категория A", kk: "A санаты", en: "Category A")),
        ]
    }
    static var surveyRegionQuestion: String { Localizer.pick(ru: "Выбери свой регион", kk: "Аймағыңды таңда", en: "Choose your region") }
    static var surveyRegionSearchHint: String { Localizer.pick(ru: "Поиск города или области", kk: "Қала немесе облысты іздеу", en: "Search city or region") }
    // NOTE: region names are Kazakhstan proper nouns kept in ru for all locales for now
    // (a localized transliteration pass is a low-priority follow-up).
    static let surveyRegions: [String] = [
        "Абайская область", "Акмолинская область", "Актюбинская область", "Алматинская область",
        "Атырауская область", "г. Актау", "г. Актобе", "г. Алматы", "г. Астана", "г. Атырау",
        "г. Караганда", "г. Кокшетау", "г. Костанай", "г. Кызылорда", "г. Павлодар",
        "г. Петропавловск", "г. Семей", "г. Талдыкорган", "г. Тараз", "г. Туркестан",
        "г. Уральск", "г. Усть-Каменогорск", "г. Шымкент", "Жамбылская область",
        "Жетысуская область", "Западно-Казахстанская область", "Восточно-Казахстанская область",
        "Карагандинская область", "Костанайская область", "Кызылординская область",
        "Мангистауская область", "Павлодарская область", "Северо-Казахстанская область",
        "Туркестанская область", "Улытауская область",
    ].sorted { $0.lowercased() < $1.lowercased() }
    static var surveyKnowledgeQuestion: String { Localizer.pick(ru: "С чего начнём твой путь к правам?", kk: "Куәлікке апарар жолыңды неден бастаймыз?", en: "Where do we start your path to a license?") }
    static var surveyKnowledgeOptions: [String] {
        [
            Localizer.pick(ru: "Я только начинаю", kk: "Мен енді бастап жатырмын", en: "I'm just starting"),
            Localizer.pick(ru: "Уже немного знаю правила", kk: "Ережелерді сәл білемін", en: "I know the rules a bit"),
            Localizer.pick(ru: "Хочу проверить знания перед экзаменом", kk: "Емтихан алдында білімімді тексергім келеді", en: "I want to check my knowledge before the exam"),
        ]
    }

    // Loading
    static var loadingStart: String { Localizer.pick(ru: "Начинаем анализ...", kk: "Талдауды бастаймыз...", en: "Starting analysis...") }
    static var loadingSteps: [(end: Double, text: String)] {
        [
            (0.30, Localizer.pick(ru: "Собираем ваши ответы...", kk: "Жауаптарыңызды жинаймыз...", en: "Collecting your answers...")),
            (0.75, Localizer.pick(ru: "Готовим план обучения...", kk: "Оқу жоспарын дайындаймыз...", en: "Preparing your study plan...")),
            (0.99, Localizer.pick(ru: "Анализируем ваш результат...", kk: "Нәтижеңізді талдаймыз...", en: "Analyzing your result...")),
        ]
    }

    // Social proof
    static var socialProofHero1: String { Localizer.pick(ru: "Приложение ", kk: "Қолданба ", en: "The ") }
    static var socialProofHero2: String { Localizer.pick(ru: "№1 ", kk: "№1 ", en: "#1 app ") }
    static var socialProofHero3: String { Localizer.pick(ru: "для подготовки\nк экзамену ПДД в РК", kk: "ҚР-да ПДД емтиханына\nдайындалуға арналған", en: "for preparing\nfor the PDD exam in Kazakhstan") }
    static var socialProofStats: [(value: String, label: String)] {
        [
            ("1 000+", Localizer.pick(ru: "вопросов\nпо ПДД РК", kk: "ПДД РК\nсұрақтары", en: "PDD RK\nquestions")),
            ("95%", Localizer.pick(ru: "сдают с\nпервого раза", kk: "бірінші реттен\nтапсырады", en: "pass on\nfirst try")),
            ("24/7", Localizer.pick(ru: "ИИ-помощник\nна связи", kk: "ЖИ-көмекші\nбайланыста", en: "AI assistant\nonline")),
        ]
    }
    static var socialProofFeatures: [(icon: String, color: String, title: String, subtitle: String)] {
        [
            ("books.vertical", "#1B8FEF", Localizer.pick(ru: "1 000+ вопросов по ПДД РК", kk: "1 000+ ПДД РК сұрағы", en: "1,000+ PDD RK questions"), Localizer.pick(ru: "Актуальная база — точно как на официальном экзамене", kk: "Өзекті база — ресми емтихандағыдай дәл", en: "Up-to-date bank — just like the official exam")),
            ("", "#34C759", Localizer.pick(ru: "ИИ-помощник Акжол", kk: "ЖИ-көмекші Ақжол", en: "AI assistant Akzhol"), Localizer.pick(ru: "Объяснит любой вопрос понятным языком 24/7", kk: "Кез келген сұрақты түсінікті тілмен 24/7 түсіндіреді", en: "Explains any question in plain language, 24/7")),
            ("play.circle", "#FF9500", Localizer.pick(ru: "Видеоуроки от инструкторов", kk: "Нұсқаушылардан бейнесабақтар", en: "Video lessons from instructors"), Localizer.pick(ru: "Разборы ситуаций на дороге с визуальными примерами", kk: "Жол жағдайларын көрнекі мысалдармен талдау", en: "Road-situation breakdowns with visual examples")),
            ("chart.bar.xaxis", "#AF52DE", Localizer.pick(ru: "Персональный анализ ошибок", kk: "Қателерді жеке талдау", en: "Personal mistake analysis"), Localizer.pick(ru: "Видишь где слабые места и работаешь именно над ними", kk: "Әлсіз тұстарыңды көріп, нақ солармен жұмыс істейсің", en: "See your weak spots and work exactly on them")),
        ]
    }
    static var socialProofReviewsTitle: String { Localizer.pick(ru: "Что говорят пользователи", kk: "Пайдаланушылар не дейді", en: "What users say") }
    static var socialProofContinue: String { Localizer.pick(ru: "Продолжить", kk: "Жалғастыру", en: "Continue") }
    static var socialProofReviews: [(name: String, date: String, text: String)] {
        [
            ("Алия М.", "12.04.2025", Localizer.pick(ru: "Сдала теорию с первого раза! Акжол объяснял каждый вопрос так понятно, что даже самые сложные знаки перестали путать. Очень советую.", kk: "Теорияны бірінші реттен тапсырдым! Ақжол әр сұрақты соншалықты түсінікті түсіндірді, тіпті ең күрделі белгілерді шатастырмайтын болдым. Кеңес беремін.", en: "Passed theory on the first try! Akzhol explained every question so clearly that even the trickiest signs stopped confusing me. Highly recommend.")),
            ("Нурлан К.", "02.05.2025", Localizer.pick(ru: "Купил подписку за три дня до экзамена — успел прогнать весь банк вопросов. Ни одного незнакомого билета не попалось. Результат — 18/20.", kk: "Емтиханға үш күн қалғанда жазылым сатып алдым — бүкіл сұрақ банкін өтіп үлгердім. Бірде-бір бейтаныс билет түскен жоқ. Нәтиже — 18/20.", en: "Bought the subscription three days before the exam — managed to run through the whole question bank. Not a single unfamiliar ticket came up. Result: 18/20.")),
            ("Дамир Т.", "18.10.2025", Localizer.pick(ru: "Видеоуроки реально помогают понять логику правил, не просто зубрёжка. Акжол всегда подскажет, если что-то непонятно — прямо как живой инструктор.", kk: "Бейнесабақтар ережелердің логикасын түсінуге шынымен көмектеседі, жай жаттау емес. Бірдеңе түсініксіз болса, Ақжол әрқашан кеңес береді — нағыз нұсқаушыдай.", en: "The video lessons really help you understand the logic of the rules, not just memorize. Akzhol always helps when something's unclear — just like a real instructor.")),
        ]
    }

    static var onboardingSlides: [(img: String, title: String, subtitle: String)] {
        [
            ("onbCar", Localizer.pick(ru: "Начни свой путь\nк водительскому\nудостоверению!", kk: "Жүргізуші куәлігіне\nапарар жолыңды\nбаста!", en: "Start your journey\nto a driver's\nlicense!"), Localizer.pick(ru: "Проходи видео-курс и выполняй задания", kk: "Бейне-курстан өтіп, тапсырмаларды орында", en: "Take the video course and complete tasks")),
            ("OnbWay", Localizer.pick(ru: "Проверь свои знания —\nпроходи пробные тесты\nпрямо в приложении", kk: "Біліміңді тексер —\nсынақ тесттерін қолданбада\nтікелей өт", en: "Check your knowledge —\ntake mock tests\nright in the app"), Localizer.pick(ru: "Отвечай на вопросы, как на экзамене", kk: "Емтихандағыдай сұрақтарға жауап бер", en: "Answer questions like on the exam")),
            ("ai_akzhol", Localizer.pick(ru: "ГАИшник Акжол — твой\nличный помощник по ПДД", kk: "Жолполициясы Ақжол — сенің\nжеке ПДД көмекшің", en: "Officer Akzhol — your\npersonal PDD assistant"), Localizer.pick(ru: "Отвечает на вопросы, помогает подготовиться к экзамену", kk: "Сұрақтарға жауап береді, емтиханға дайындалуға көмектеседі", en: "Answers questions, helps you prepare for the exam")),
            ("OnbCross", Localizer.pick(ru: "Понятные объяснения\nс наглядными анимациями\nи примерами", kk: "Көрнекі анимациялар\nмен мысалдармен\nтүсінікті түсіндірмелер", en: "Clear explanations\nwith visual animations\nand examples"), Localizer.pick(ru: "Учись легко и эффективно", kk: "Оңай әрі тиімді үйрен", en: "Learn easily and effectively")),
        ]
    }
}
