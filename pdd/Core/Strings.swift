//
//  Strings.swift
//  pdd
//
//  Russian UI strings taken verbatim from app_localizations_ru.dart.
//  (Primary locale; kk/en localization is a follow-up.)
//

import Foundation

enum L {
    // Nav
    static let navTests = "Тесты"
    static let navAkzhol = "Акжол"
    static let navProfile = "Профиль"

    // Tests
    static let testMainTitle = "Пробное\nтестирование\nПДД РК"
    static let testStartTrialBtn = "Начать пробное тестирование"
    static let testPageTitle = "Пробное тестирование ПДД РК"
    static let testPageTitleIndividual = "Индивидуальное тестирование"
    static let testDescriptionMain = "Это тренировочный экзамен, составленный на основе актуальных правил дорожного движения Республики Казахстан. Тест помогает проверить уровень знаний, выявить ошибки и подготовиться к реальной сдаче теоретического экзамена в спецЦОНе. Подходит как для начинающих водителей, так и для тех, кто хочет освежить знания. Наш пробный тест полностью соответствует действующим ПДД РК и формату экзамена. После прохождения ты увидишь свои ошибки и поймёшь, что нужно подтянуть. Проходи сколько угодно — это бесплатно и без ограничений"
    static let testDescriptionIndividual = "Хочешь сдать ПДД без второго шанса?\nНачни с умной подготовки. Этот тест адаптирован под тебя: он не тратит время на то, что ты уже знаешь, и бьёт точно по ошибкам."
    static let workOnMistakes = "Провести работу над ошибками с Акжол"
    static let workOnMistakesShort = "Работа над ошибками"
    static let individualTestingAiDesc = "ИИ-ассистент специально подготовил для тебя тест, основанный на твоих ошибках и темах, где ты чаще всего допускаешь неточности."
    static let startTestingBtn = "Начать тестирование"
    static let recommended = "Рекомендуем"
    static let trialTestingShort = "Пробное тестирование"
    static let testHistoryTitle = "История тестирований"
    static let testHistorySubtitle = "История сохраняется на устройстве. Ниже — последние 8 записей."
    static let testHistoryShowAll = "Все"
    static let testHistoryFullTitle = "Вся история"
    static let testHistoryEmpty = "Здесь появятся записи после полного прохождения пробного теста"
    static let testDetailAppBarTitle = "Пробное тестирование"
    static let questionsCountLabel = "Количество вопросов:"
    static let passRequirementLabel = "Для успешной сдачи необходимо:"
    static let mistakesEmptyStartHint = "Пока в работе над ошибками нет вопросов. Сначала пройдите тест и допустите ошибки — они автоматически появятся здесь."

    static func testHistoryRowSubtitle(_ score: Int, _ total: Int, _ date: String) -> String {
        "\(score)/\(total) · \(date)"
    }

    // Road-sign detector promo
    static let roadsignDetector = "Определитель\nдорожных знаков"
    static let go = "Перейти"

    // Quiz
    static let quizCheck = "Проверить"
    static let quizNext = "Далее"
    static let quizFinish = "Завершить"
    static let quizCorrectPrefix = "Правильно: "
    static let askAkzhol = "Спросить Акжола"
    static let aiDefaultQuestion = "Почему мой ответ был неправильным?"
    static let quizReplayUnavailable = "Не удалось открыть этот тест. Запись устарела или вопросы обновились."

    // Results
    static let resultSuccessSubtitle = "Отлично! Ты бы сдал экзамен 🎉\nПродолжай тренироваться,\nчтобы на реальной сдаче\nне было ни единого сомнения"
    static let resultFailSubtitle = "Этого балла недостаточно для\nуспешного прохождения теста"
    static let resultAkzholBubble = "Акжол не готов вас пропустить дальше"
    static let resultNextTest = "Перейди на следующий тест"
    static let resultTryAgain = "Попробовать еще"
    static let completionTitle = "Вы уже на шаг ближе\nк своим правам!"
    static let completionSubtitle = "Продолжайте обучение и будьте готовы\nк успешной сдаче экзамена"
    static let continueBtn = "Продолжить"

    static func resultScore(_ s: Int, _ t: Int) -> String { "\(s) из \(t)" }

    // Akzhol AI
    static let akzholGreeting = "Здравия желаю,\nменя зовут Акжол"
    static let akzholCanHelp = "Я могу вам помочь с:"
    static let akzholName = "Акжол"
    static let akzholRole = "Сотрудник МВД РК"
    static let chatInputHint = "Напишите свой вопрос"
    static let akzholCard1Title = "С решением вопросов\nпо ПДД РК"
    static let akzholCard1Subtitle = "Оформление ДТП, спорные ситуации и\nвзаимодействие с органами — быстро,\nпрофессионально и в рамках закона"
    static let akzholCard2Title = "Помогу тебе с\nэкзаменационными\nвопросами ПДД"
    static let akzholCard2Subtitle = "Разбираем спорные формулировки,\nобновлённые требования и реальные\nдорожные ситуации"
    static let akzholCard3Title = "Отвечу на любые твои\nвопросы по вождению"
    static let akzholCard3Subtitle = "От теории ПДД до реальных ситуаций\nна дороге. Объясняю понятно, без\nзанудства и лишних терминов"
    static let freemiumAkzholLimitTitle = "Лимит Акжола"
    static let freemiumAkzholLimitBody = "Бесплатно доступны 3 ответа Акжола. Оформите Premium, чтобы общаться без ограничений."
    static let freemiumOpenPremium = "Оформить Premium"

    // Profile
    static let profileDemoUserName = "Гость"
    static let licenseCatB = "Категория B"
    static let profileLevelTitle = "Прогресс"
    static let profileLevelLearner = "Ученик"
    static let profileLevelDriver = "Водитель"
    static let profileLevelExpert = "Эксперт"
    static let profileNotifications = "Уведомления"
    static let profileHaptics = "Вибрация"
    static let favoritesTitle = "Избранное"
    static let editProfile = "Редактировать профиль"
    static let selectLanguage = "Язык"
    static let privacyPolicy = "Политика конфиденциальности"
    static let termsOfUse = "Условия использования"
    static let animationsToggle = "Анимации"
    static let rateApp = "Оценить приложение"
    static let shareApp = "Поделиться приложением"
    static let deleteAccount = "Удалить аккаунт"
    static let logoutTitle = "Выйти из аккаунта"
    static let logoutConfirmTitle = "Выйти из аккаунта?"
    static let logoutConfirmMessage = "Вы выйдете из профиля и вернётесь на экран приветствия."
    static let logoutConfirmButton = "Выйти"
    static let cancel = "Отмена"
    static let supportTitle = "Служба поддержки"
    static let supportSubtitle = "Поможем если столкнетесь с проблемой"
    static let premium = "Premium"
    static let langSelectionTitle = "Выбор языка"

    static func profileCorrectAnswersProgress(_ done: Int, _ total: Int) -> String {
        "Правильных ответов: \(done) из \(total)"
    }

    // Paywall
    static let paywallHeroPrefix = "Начни с "
    static let paywallHeroHighlight = "3 дней бесплатно"
    static let paywallSubtitle = "Видеоуроки, все тесты, ИИ-помощник\nАкжол — без ограничений"
    static let paywallFeatureVideos = "Все видеоуроки без ограничений"
    static let paywallFeatureTests = "Полный банк тестовых вопросов"
    static let paywallFeatureAkzhol = "Неограниченные чаты с Акжолом"
    static let paywallFeatureMistakes = "Персональный анализ ошибок"
    static let paywallPlanWeekly = "Неделя"
    static let paywallPlanMonthly = "Месяц"
    static let paywallPriceWeekly = "990 ₸"
    static let paywallPriceMonthly = "2 490 ₸"
    static let paywallPeriodWeekly = "в неделю"
    static let paywallPeriodMonthly = "в месяц"
    static let paywallPerDayWeekly = "141 ₸/день"
    static let paywallPerDayMonthly = "83 ₸/день"
    static let paywallBadgeBestDeal = "Лучшее предложение"
    static let paywallCancelAnytime = "Отмена в любое время"
    static let paywallDisclaimerAfterTrial = "После пробного периода спишется стоимость\nвыбранного плана. Подписка автопродляется."
    static let paywallRestorePurchases = "Восстановить покупки"
    static func paywallCtaWithPrice(_ price: String) -> String { "Продолжить за \(price)" }

    // Onboarding
    static let onboardingNext = "Далее"
    static let onboardingStart = "Начать"
    // Survey
    static let surveyNext = "Следующий вопрос"
    static let surveyFinish = "Завершить"
    static let surveyVehicleQuestion = "На каком транспортном средстве ты планируешь передвигаться?"
    static let surveyVehicleOptions: [(id: String, icon: String, title: String, subtitle: String)] = [
        ("car", "Car", "Легковой автомобиль", "Категория B"),
        ("truck", "Truck", "Грузовик", "Категория C, D"),
        ("bike", "Bike", "Мотоцикл", "Категория A"),
    ]
    static let surveyRegionQuestion = "Выбери свой регион"
    static let surveyRegionSearchHint = "Поиск города или области"
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
    static let surveyKnowledgeQuestion = "С чего начнём твой путь к правам?"
    static let surveyKnowledgeOptions = ["Я только начинаю", "Уже немного знаю правила", "Хочу проверить знания перед экзаменом"]

    // Loading
    static let loadingStart = "Начинаем анализ..."
    static let loadingSteps: [(end: Double, text: String)] = [
        (0.30, "Собираем ваши ответы..."),
        (0.75, "Готовим план обучения..."),
        (0.99, "Анализируем ваш результат..."),
    ]

    // Social proof
    static let socialProofHero1 = "Приложение "
    static let socialProofHero2 = "№1 "
    static let socialProofHero3 = "для подготовки\nк экзамену ПДД в РК"
    static let socialProofStats: [(value: String, label: String)] = [
        ("1 000+", "вопросов\nпо ПДД РК"), ("95%", "сдают с\nпервого раза"), ("24/7", "ИИ-помощник\nна связи"),
    ]
    static let socialProofFeatures: [(icon: String, color: String, title: String, subtitle: String)] = [
        ("books.vertical", "#1B8FEF", "1 000+ вопросов по ПДД РК", "Актуальная база — точно как на официальном экзамене"),
        ("", "#34C759", "ИИ-помощник Акжол", "Объяснит любой вопрос понятным языком 24/7"),
        ("play.circle", "#FF9500", "Видеоуроки от инструкторов", "Разборы ситуаций на дороге с визуальными примерами"),
        ("chart.bar.xaxis", "#AF52DE", "Персональный анализ ошибок", "Видишь где слабые места и работаешь именно над ними"),
    ]
    static let socialProofReviewsTitle = "Что говорят пользователи"
    static let socialProofContinue = "Продолжить"
    static let socialProofReviews: [(name: String, date: String, text: String)] = [
        ("Алия М.", "12 апр 2025", "Сдала теорию с первого раза! Акжол объяснял каждый вопрос так понятно, что даже самые сложные знаки перестали путать. Очень советую."),
        ("Нурлан К.", "2 мая 2025", "Купил подписку за три дня до экзамена — успел прогнать весь банк вопросов. Ни одного незнакомого билета не попалось. Результат — 18/20."),
        ("Дамир Т.", "18 окт 2025", "Видеоуроки реально помогают понять логику правил, не просто зубрёжка. Акжол всегда подскажет, если что-то непонятно — прямо как живой инструктор."),
    ]

    static let onboardingSlides: [(img: String, title: String, subtitle: String)] = [
        ("onbCar", "Начни свой путь\nк водительскому\nудостоверению!", "Проходи видео-курс и выполняй задания"),
        ("OnbWay", "Проверь свои знания —\nпроходи пробные тесты\nпрямо в приложении", "Отвечай на вопросы, как на экзамене"),
        ("ai_akzhol", "ГАИшник Акжол — твой\nличный помощник по ПДД", "Отвечает на вопросы, помогает подготовиться к экзамену"),
        ("OnbCross", "Понятные объяснения\nс наглядными анимациями\nи примерами", "Учись легко и эффективно"),
    ]
}
