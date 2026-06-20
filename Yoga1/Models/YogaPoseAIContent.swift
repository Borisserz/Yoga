import Foundation

struct AIPoseAnalysisData: Hashable {
    let technique: String
    let pros: [String]
    let cons: [String]
    let targetedMuscles: [String]
    let aiTip: String
}

enum YogaPoseAIContent {
    static func getAnalysis(for key: String) -> AIPoseAnalysisData {
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        let isRussian = (language == "ru")
        
        if isRussian {
            return ruData[key] ?? defaultRu(key)
        } else {
            return enData[key] ?? defaultEn(key)
        }
    }
    
    private static func defaultEn(_ key: String) -> AIPoseAnalysisData {
        AIPoseAnalysisData(
            technique: "Align your body carefully. Keep your breath steady and focus on maintaining stability and length through the spine.",
            pros: ["Improves body awareness", "Increases strength and flexibility", "Promotes mindful breathing"],
            cons: ["Recent injuries to active joints", "Listen to your body and stop if you feel sharp pain"],
            targetedMuscles: ["Core", "Spine"],
            aiTip: "Focus on slow, deep exhalations to deepen the stretch or hold."
        )
    }
    
    private static func defaultRu(_ key: String) -> AIPoseAnalysisData {
        AIPoseAnalysisData(
            technique: "Тщательно выравнивайте тело. Поддерживайте ровное дыхание и сфокусируйтесь на стабильности и вытяжении позвоночника.",
            pros: ["Улучшает осознанность тела", "Увеличивает силу и гибкость", "Способствует осознанному дыханию"],
            cons: ["Недавние травмы задействованных суставов", "Слушайте свое тело и прекращайте при острой боли"],
            targetedMuscles: ["Кор", "Позвоночник"],
            aiTip: "Фокусируйтесь на медленном, глубоком выдохе, чтобы углубить растяжку или удержание."
        )
    }
    
    private static let enData: [String: AIPoseAnalysisData] = [
        "balasana": AIPoseAnalysisData(
            technique: "Rest your hips back onto your heels with your knees slightly apart. Extend your arms forward, palms flat, or lay them beside your torso. Let your forehead rest gently on the mat, completely releasing tension in your shoulders and lower back.",
            pros: ["Deeply relaxes the nervous system", "Gently stretches hips, thighs, and ankles", "Relieves neck and shoulder tension"],
            cons: ["Knee injury", "Pregnancy (late stages)", "Diarrhea"],
            targetedMuscles: ["Glutes", "Lower Back", "Shoulders"],
            aiTip: "Inhale into the back of your ribs, feeling your spine expand with each breath."
        ),
        "bridge": AIPoseAnalysisData(
            technique: "Lie on your back, bend your knees, and place feet flat on the floor hip-width apart. Pressing into your feet and arms, lift your hips toward the ceiling. Roll your shoulders underneath you and clasp your hands to lift higher.",
            pros: ["Strengthens glutes, hamstrings, and lower back", "Opens chests, neck, and spine", "Improves blood circulation"],
            cons: ["Recent neck or shoulder injury", "Severe back pain"],
            targetedMuscles: ["Glutes", "Hamstrings", "Erectors", "Chest"],
            aiTip: "Keep your thighs parallel. Do not let your knees splay outward as you lift your pelvis."
        ),
        "cat_cow": AIPoseAnalysisData(
            technique: "Begin on hands and knees. For Cow (Inhale): drop your belly toward the mat, lift your chest and chin, looking upward. For Cat (Exhale): draw your belly button to your spine, round your back, and let your head release toward the floor.",
            pros: ["Warms up the spine and improves flexibility", "Synchronizes breath with movement", "Relieves stress and calms the mind"],
            cons: ["Recent neck injury (keep head aligned)", "Wrist sensitivity"],
            targetedMuscles: ["Spine", "Core", "Shoulders"],
            aiTip: "Initiate each movement from your tailbone, letting it ripple through your spine to your head."
        ),
        "cobra": AIPoseAnalysisData(
            technique: "Lie prone with tops of feet flat. Place hands under shoulders, elbows tucked close to your ribs. Inhale, press into your hands, and lift your chest off the floor, keeping your lower body engaged and shoulders relaxed down.",
            pros: ["Strengthens the spine and back muscles", "Opens lungs and chest", "Stimulates abdominal organs"],
            cons: ["Carpal tunnel syndrome", "Pregnancy", "Recent abdominal surgery"],
            targetedMuscles: ["Lower Back", "Shoulders", "Triceps", "Abs"],
            aiTip: "Use your back strength to lift rather than pushing up solely with your arms. Keep neck long."
        ),
        "corpse": AIPoseAnalysisData(
            technique: "Lie flat on your back, legs extended and slightly apart, feet splayed out. Arms rest alongside your body, palms facing up. Close your eyes, slow your breathing, and systematically release all muscle tension.",
            pros: ["Deeply calms the central nervous system", "Lowers blood pressure and heart rate", "Reduces anxiety, headache, and fatigue"],
            cons: ["Severe back discomfort (use a bolster under knees)"],
            targetedMuscles: ["Whole Body (Relaxation)"],
            aiTip: "Let your body feel heavy, as if sinking into the earth, and clear your mind of all active thoughts."
        ),
        "downward_dog": AIPoseAnalysisData(
            technique: "Start on all fours, tuck your toes, and lift your hips up and back, forming an inverted 'V'. Press firmly through your knuckles, extend your spine, and reach your heels down while pulling your belly in.",
            pros: ["Builds strength in arms, shoulders, and wrists", "Stretches calves, hamstrings, and shoulders", "Energizes the whole body"],
            cons: ["Carpal tunnel syndrome", "High blood pressure", "Late-term pregnancy"],
            targetedMuscles: ["Hamstrings", "Calves", "Deltoids", "Triceps"],
            aiTip: "Prioritize a straight spine over straight legs; bend your knees if your lower back rounds."
        ),
        "tadasana": AIPoseAnalysisData(
            technique: "Stand with feet together or hip-width apart. Root down through all four corners of your feet. Engage your thighs, draw your belly in, roll your shoulders back and down, and reach the crown of your head upward.",
            pros: ["Improves posture and body alignment", "Strengthens thighs, knees, and ankles", "Centers mind and improves focus"],
            cons: ["Headache", "Vertigo / low blood pressure"],
            targetedMuscles: ["Quadriceps", "Core", "Ankles"],
            aiTip: "Distribute your weight equally across both feet and feel space expanding between your vertebrae."
        ),
        "vrksasana": AIPoseAnalysisData(
            technique: "Shift your weight to your left leg. Place the sole of your right foot on your left inner ankle, calf, or upper thigh (avoiding the knee). Bring your hands to heart center or reach them overhead like branches.",
            pros: ["Enhances physical balance and stability", "Strengthens tendons in feet and ankles", "Improves mental concentration"],
            cons: ["Knee injury", "Recent ankle sprain"],
            targetedMuscles: ["Ankles", "Calves", "Adductors", "Core"],
            aiTip: "Find a non-moving point (Drishti) on the floor or wall in front of you to stabilize your gaze."
        ),
        "warrior_i": AIPoseAnalysisData(
            technique: "Step your left foot back about 3-4 feet, turning the heel in 45 degrees. Bend your right knee directly over the ankle. Square your hips toward the front of the mat and reach your arms overhead.",
            pros: ["Strengthens legs, ankles, and core", "Stretches groin, chest, and shoulders", "Increases stamina and confidence"],
            cons: ["Heart conditions or high blood pressure", "Shoulder injury (keep hands on hips)"],
            targetedMuscles: ["Quadriceps", "Glutes", "Hip Flexors", "Shoulders"],
            aiTip: "Press firmly into the outer edge of your back foot to protect your back knee and align your hips."
        ),
        "warrior_ii": AIPoseAnalysisData(
            technique: "Step one foot back 3-4 feet, turning the foot 90 degrees out. Bend the front knee to 90 degrees, keeping it aligned over the second toe. Extend arms parallel to the floor, gazing over the front fingertips.",
            pros: ["Strengthens quadriceps, calves, and ankles", "Opens hips, groin, and chest", "Builds focus and physical endurance"],
            cons: ["Recent knee surgery", "Chronic neck problems (do not turn head)"],
            targetedMuscles: ["Quadriceps", "Glutes", "Deltoids", "Adductors"],
            aiTip: "Keep your torso stacked directly over your pelvis; avoid leaning forward over the front knee."
        ),
        "boat": AIPoseAnalysisData(
            technique: "Sit on your sit bones. Lean back slightly, lift your legs, and bend your knees or straighten them to a 45-degree angle. Extend your arms parallel to the floor, chest lifted, and keep your core braced.",
            pros: ["Deeply strengthens abdominal muscles and hip flexors", "Improves balance and digestion", "Strengthens the spine"],
            cons: ["Asthma", "Heart disease", "Lower back injury"],
            targetedMuscles: ["Rectus Abdominis", "Hip Flexors", "Spine Erectors"],
            aiTip: "Keep your collarbones wide and chest lifted. Avoid rounding your spine or collapsing your back."
        ),
        "plank": AIPoseAnalysisData(
            technique: "From all fours, step feet back so legs are fully extended. Align shoulders directly over wrists. Keep your body in a straight line from head to heels, engaging your core, glutes, and thighs.",
            pros: ["Tones all major muscle groups", "Strengthens shoulders, chest, and arms", "Improves core stability and posture"],
            cons: ["Carpal tunnel syndrome", "Recent wrist or shoulder injury"],
            targetedMuscles: ["Core", "Deltoids", "Pectorals", "Quadriceps"],
            aiTip: "Push the floor away with your hands, spreading your shoulder blades wide and squeezing your glutes."
        ),
        "seated_forward_bend": AIPoseAnalysisData(
            technique: "Sit tall with legs straight in front. Inhale, reach up. Exhale, hinge at your hips and fold forward. Hold your feet, ankles, or shins, keeping your spine long and shoulders relaxed.",
            pros: ["Stretches the entire back body and hamstrings", "Calms the mind and relieves mild anxiety", "Stimulates digestion and kidney function"],
            cons: ["Asthma", "Herniated disc in the spine"],
            targetedMuscles: ["Hamstrings", "Calves", "Spine Erectors"],
            aiTip: "Focus on drawing your chest toward your toes rather than your forehead toward your knees."
        ),
        "seated_twist": AIPoseAnalysisData(
            technique: "Sit with legs extended. Bend the right knee and place the foot outside the left thigh. Inhale, lift your spine. Exhale, wrap your left arm around your right knee and place right hand behind you, twisting gently.",
            pros: ["Increases spinal flexibility and mobility", "Stretches outer hips and glutes", "Stimulates digestion and inner organs"],
            cons: ["Severe back or spine injury"],
            targetedMuscles: ["Obliques", "Gluteus Medius", "Spine Rotators"],
            aiTip: "Lengthen your spine upward on each inhale, and gently deepen the twist on each exhale."
        ),
        "triangle": AIPoseAnalysisData(
            technique: "Stand with feet wide. Turn one foot 90 degrees out. Extend arms wide, reach forward over the front leg, and hinge down. Place the bottom hand on your shin, block, or floor, and reach the top hand up.",
            pros: ["Stretches hips, groin, hamstrings, and chest", "Strengthens thighs, knees, and ankles", "Helps relieve back pain"],
            cons: ["Low blood pressure / migraine", "Neck issues (look forward instead of up)"],
            targetedMuscles: ["Obliques", "Hamstrings", "Adductors", "Chest"],
            aiTip: "Imagine you are pressed flat between two panes of glass, keeping your hips and chest open."
        ),
        "utkatasana": AIPoseAnalysisData(
            technique: "Stand tall. Inhale and reach your arms up. Exhale, bend your knees, and lower your hips as if sitting back into an invisible chair. Keep your weight in your heels and lift your torso.",
            pros: ["Strengthens calves, ankles, thighs, and spine", "Stretches shoulders and chest", "Stimulates abdominal organs and diaphragm"],
            cons: ["Chronic knee pain", "Insomnia / headaches"],
            targetedMuscles: ["Quadriceps", "Glutes", "Ankles", "Erectors"],
            aiTip: "Keep your lower belly drawn in to protect the lower back and prevent excessive arching."
        ),
        "bakasana": AIPoseAnalysisData(
            technique: "Squat down, place hands flat on the floor shoulder-width apart. Place knees high up on your triceps. Shift your weight forward, lift one foot, then the other, balancing solely on your arms.",
            pros: ["Builds immense arm, wrist, and shoulder strength", "Develops deep core and abdominal control", "Improves balance and body confidence"],
            cons: ["Carpal tunnel syndrome", "Pregnancy", "Wrist fracture or injury"],
            targetedMuscles: ["Triceps", "Anterior Deltoids", "Core", "Wrists"],
            aiTip: "Look forward, not down at the floor. Where your eyes look, your body will naturally balance."
        ),
        "camel": AIPoseAnalysisData(
            technique: "Kneel hip-width apart. Place hands on your lower back. Inhale, lift your chest, and gently arch back. If accessible, reach down to grab your heels, keeping hips aligned directly over your knees.",
            pros: ["Opens the entire front body and chest", "Stretches deep hip flexors", "Improves spinal extension and flexibility"],
            cons: ["Serious back or neck injury", "High or low blood pressure"],
            targetedMuscles: ["Pectorals", "Rectus Abdominis", "Hip Flexors", "Quads"],
            aiTip: "Press your hips forward to keep them stacked over your knees. Protect your neck by keeping chin tucked."
        ),
        "half_moon": AIPoseAnalysisData(
            technique: "From a standing position, place one hand on the floor/block ahead of your foot. Lift your back leg parallel to the floor, open your hips and torso sideways, and reach the top hand toward the sky.",
            pros: ["Improves leg stability and single-leg balance", "Opens chest, shoulders, and hips", "Strengthens thighs and ankles"],
            cons: ["Vertigo or dizziness", "Recent knee or ankle injuries"],
            targetedMuscles: ["Gluteus Medius", "Hamstrings", "Ankles", "Core"],
            aiTip: "Engage the foot and quad of the lifted leg to act as a counter-weight, stabilizing your stance."
        ),
        "pigeon": AIPoseAnalysisData(
            technique: "From all fours, slide your right knee forward behind your right wrist, angling the right shin. Extend your left leg straight back. Align your hips square, and gently lower your torso forward.",
            pros: ["Deeply opens the hip joints and outer glutes", "Releases deep mental and physical stress", "Stretches the piriformis muscle"],
            cons: ["Knee injury", "Sacroiliac (SI) joint issues"],
            targetedMuscles: ["Gluteus Maximus", "Piriformis", "Psoas", "Groin"],
            aiTip: "Keep your hips level. Put a cushion or block under the hip of the bent leg if it floats high."
        )
    ]
    
    private static let ruData: [String: AIPoseAnalysisData] = [
        "balasana": AIPoseAnalysisData(
            technique: "Опустите таз на пятки, слегка разведя колени в стороны. Вытяните руки вперед ладонями вниз или положите их вдоль туловища. Мягко опустите лоб на коврик, полностью расслабляя плечи и поясницу.",
            pros: ["Глубоко расслабляет нервную систему", "Мягко растягивает бедра, голени и щиколотки", "Снимает напряжение в шее и плечах"],
            cons: ["Травмы коленей", "Поздние сроки беременности", "Диарея"],
            targetedMuscles: ["Ягодицы", "Поясница", "Плечи"],
            aiTip: "Направляйте вдох в задние ребра, чувствуя, как расширяется позвоночник с каждым дыханием."
        ),
        "bridge": AIPoseAnalysisData(
            technique: "Лягте на спину, согните колени и поставьте стопы на пол на ширине бедер. Прижимая стопы и руки к полу, поднимите таз вверх. Сведите лопатки ближе друг к другу и сцепите руки в замок.",
            pros: ["Укрепляет ягодицы, заднюю поверхность бедер и поясницу", "Раскрывает грудную клетку, шею и позвоночник", "Улучшает кровообращение"],
            cons: ["Недавние травмы шеи или плеч", "Острая боль в спине"],
            targetedMuscles: ["Ягодицы", "Заднее бедро", "Разгибатели спины", "Грудь"],
            aiTip: "Держите бедра параллельно. Не позволяйте коленям расходиться в стороны при подъеме таза."
        ),
        "cat_cow": AIPoseAnalysisData(
            technique: "Встаньте на четвереньки. Для Коровы (Вдох): прогните спину вниз, потянитесь грудной клеткой и подбородком вверх. Для Кошки (Выдох): подтяните пупок к позвоночнику, округлите спину и опустите голову.",
            pros: ["Разогревает позвоночник и повышает его гибкость", "Синхронизирует дыхание с движением тела", "Снимает стресс и успокаивает ум"],
            cons: ["Травмы шеи (не поднимайте высоко голову)", "Чувствительность запястий"],
            targetedMuscles: ["Позвоночник", "Кор", "Плечи"],
            aiTip: "Начинайте каждое движение от копчика, позволяя ему волной прокатиться по всему позвоночнику."
        ),
        "cobra": AIPoseAnalysisData(
            technique: "Лягте на живот, прижмите подножия стоп к полу. Поместите ладони под плечи, прижав локти к ребрам. На вдохе оттолкнитесь руками и поднимите грудь, расслабляя плечи вниз.",
            pros: ["Укрепляет позвоночник и мышцы спины", "Раскрывает легкие и грудной отдел", "Стимулирует органы брюшной полости"],
            cons: ["Синдром запястного канала", "Беременность", "Недавние операции на брюшной полости"],
            targetedMuscles: ["Поясница", "Плечи", "Трицепсы", "Пресс"],
            aiTip: "Поднимайте тело за счет мышц спины, а не только толкаясь руками. Держите шею вытянутой."
        ),
        "corpse": AIPoseAnalysisData(
            technique: "Лягте на спину, выпрямите ноги и слегка разведите их, носки смотрят наружу. Руки лежат вдоль тела ладонями вверх. Закройте глаза, дышите медленно и полностью расслабьте все мышцы.",
            pros: ["Глубоко успокаивает центральную нервную систему", "Снижает артериальное давление и пульс", "Уменьшает тревожность, головную боль и усталость"],
            cons: ["Сильный дискомфорт в пояснице (положите валик под колени)"],
            targetedMuscles: ["Все тело (релаксация)"],
            aiTip: "Почувствуйте тяжесть в теле, словно оно погружается в землю, и освободите ум от любых мыслей."
        ),
        "downward_dog": AIPoseAnalysisData(
            technique: "Встаньте на четвереньки, подверните пальцы ног и поднимите таз вверх и назад, принимая форму перевернутой буквы 'V'. Толкайтесь ладонями, вытягивая спину и стремясь пятками к полу.",
            pros: ["Укрепляет руки, плечи и запястья", "Растягивает икры, заднюю поверхность бедра и плечи", "Наполняет все тело энергией"],
            cons: ["Синдром запястного канала", "Высокое кровяное давление", "Поздние сроки беременности"],
            targetedMuscles: ["Заднее бедро", "Икры", "Дельты", "Трицепсы"],
            aiTip: "Прямая спина важнее прямых ног. Слегка согните колени, если округляется поясница."
        ),
        "tadasana": AIPoseAnalysisData(
            technique: "Встаньте ровно, стопы вместе или на ширине бедер. Равномерно распределите вес. Подтяните бедра и живот, расправьте плечи вниз и потянитесь макушкой к небу.",
            pros: ["Улучшает осанку и выравнивание тела", "Укрепляет бедра, колени и щиколотки", "Центрирует ум и улучшает концентрацию"],
            cons: ["Головная боль", "Головокружение / низкое давление"],
            targetedMuscles: ["Квадрицепсы", "Кор", "Лодыжки"],
            aiTip: "Почувствуйте, как стопы укореняются в землю, создавая устойчивую и прочную основу."
        ),
        "vrksasana": AIPoseAnalysisData(
            technique: "Перенесите вес на левую ногу. Поместите подошву правой стопы на внутреннюю лодыжку, икру или бедро левой ноги (избегая области колена). Соедините ладони у груди или поднимите руки вверх.",
            pros: ["Развивает физическое равновесие и координацию", "Укрепляет сухожилия стоп и голеностоп", "Повышает концентрацию внимания"],
            cons: ["Травмы коленей", "Недавние растяжения голеностопа"],
            targetedMuscles: ["Лодыжки", "Икры", "Приводящие мышцы", "Кор"],
            aiTip: "Сфокусируйте взгляд на неподвижной точке (Дришти) перед собой на полу или стене."
        ),
        "warrior_i": AIPoseAnalysisData(
            technique: "Сделайте широкий шаг левой ногой назад (около 1 метра), развернув стопу на 45 градусов. Согните правое колено ровно над лодыжкой. Разверните таз вперед и поднимите руки вверх.",
            pros: ["Укрепляет ноги, лодыжки и мышцы кора", "Растягивает пах, грудь и плечевой пояс", "Повышает выносливость и уверенность"],
            cons: ["Заболевания сердца или высокое давление", "Травмы плеч (держите руки на бедрах)"],
            targetedMuscles: ["Квадрицепсы", "Ягодицы", "Сгибатели бедра", "Плечи"],
            aiTip: "Плотно прижимайте внешний край задней стопы к коврику для защиты колена."
        ),
        "warrior_ii": AIPoseAnalysisData(
            technique: "Сделайте широкий шаг назад, развернув заднюю стопу на 90 градусов. Согните переднее колено до угла 90 градусов. Вытяните руки параллельно полу и направьте взгляд поверх передней руки.",
            pros: ["Укрепляет квадрицепсы, икроножные мышцы и лодыжки", "Раскрывает бедра, паховую область и грудь", "Развивает концентрацию и выносливость"],
            cons: ["Недавние операции на колене", "Проблемы с шеей (не поворачивайте голову)"],
            targetedMuscles: ["Квадрицепсы", "Ягодицы", "Дельты", "Приводящие"],
            aiTip: "Удерживайте корпус строго вертикально над тазом, избегайте наклона вперед за передней рукой."
        ),
        "boat": AIPoseAnalysisData(
            technique: "Сядьте на седалищные кости. Слегка отклонитесь назад, поднимите ноги согнутыми или прямыми под углом 45 градусов. Вытяните руки параллельно полу, удерживая грудь поднятой.",
            pros: ["Глубоко укрепляет мышцы живота и сгибатели бедра", "Улучшает баланс и стимулирует пищеварение", "Укрепляет мышечный корсет спины"],
            cons: ["Астма", "Заболевания сердца", "Травмы поясницы"],
            targetedMuscles: ["Прямая мышца живота", "Сгибатели бедра", "Мышцы спины"],
            aiTip: "Раскрывайте ключицы в стороны. Не скругляйте спину и не заваливайте поясницу назад."
        ),
        "plank": AIPoseAnalysisData(
            technique: "Из положения на четвереньках вытяните ноги назад. Плечи должны быть строго над запястьями. Удерживайте тело в одну линию от макушки до пяток, напрягая кор, ягодицы и бедра.",
            pros: ["Приводит в тонус все крупные группы мышц", "Укрепляет плечи, грудную клетку и руки", "Повышает стабильность кора и улучшает осанку"],
            cons: ["Синдром запястного канала", "Недавние травмы запястий или плеч"],
            targetedMuscles: ["Кор", "Дельты", "Грудные мышцы", "Квадрицепсы"],
            aiTip: "Активно отталкивайтесь руками от пола, разводя лопатки шире и не позволяя тазу провисать."
        ),
        "seated_forward_bend": AIPoseAnalysisData(
            technique: "Сядьте ровно, выпрямив ноги перед собой. На вдохе потянитесь вверх. На выдохе наклонитесь вперед от тазобедренных суставов, захватывая стопы или голени с прямой спиной.",
            pros: ["Растягивает всю заднюю поверхность тела и подколенные сухожилия", "Успокаивает ум, снимает легкую тревогу", "Стимулирует работу органов пищеварения"],
            cons: ["Астма", "Грыжи межпозвоночных дисков"],
            targetedMuscles: ["Заднее бедро", "Икры", "Разгибатели позвоночника"],
            aiTip: "Стремитесь направить грудную клетку к пальцам ног, а не лоб к коленям, сохраняя спину ровной."
        ),
        "seated_twist": AIPoseAnalysisData(
            technique: "Сядьте прямо. Согните правое колено и поставьте стопу за левое бедро. На вдохе вытяните позвоночник вверх. На выдохе обнимите левой рукой правое колено и скрутитесь вправо.",
            pros: ["Улучшает гибкость и подвижность позвоночника", "Растягивает внешнюю сторону бедер и ягодицы", "Стимулирует пищеварение и работу печени"],
            cons: ["Травмы спины или позвоночника в острой фазе"],
            targetedMuscles: ["Косые мышцы живота", "Средняя ягодичная", "Вращатели спины"],
            aiTip: "С каждым вдохом вытягивайтесь макушкой вверх, а с каждым выдохом мягко углубляйте скручивание."
        ),
        "triangle": AIPoseAnalysisData(
            technique: "Встаньте широко. Разверните правую стопу наружу на 90 градусов. Вытяните руки, потянитесь вправо и наклонитесь вбок, опуская руку на голень или пол. Левую руку вытяните вверх.",
            pros: ["Растягивает бедра, пах, подколенные сухожилия и грудь", "Укрепляет бедра, колени и лодыжки", "Помогает облегчить боли в спине"],
            cons: ["Низкое давление / мигрень", "Боли в шее (направляйте взгляд вперед)"],
            targetedMuscles: ["Косые мышцы", "Заднее бедро", "Приводящие", "Грудные"],
            aiTip: "Представьте, что вы прижаты к стене лопатками и тазом, удерживая плоскость тела ровной."
        ),
        "utkatasana": AIPoseAnalysisData(
            technique: "Встаньте прямо. На вдохе поднимите руки вверх. На выдохе согните колени и опустите таз, словно садитесь на невидимый стул. Перенесите вес на пятки.",
            pros: ["Укрепляет икры, лодыжки, бедра и позвоночник", "Растягивает плечевой пояс и грудь", "Стимулирует работу диафрагмы"],
            cons: ["Хронические боли в коленях", "Бессонница или головная боль"],
            targetedMuscles: ["Квадрицепсы", "Ягодицы", "Лодыжки", "Разгибатели спины"],
            aiTip: "Слегка подтягивайте нижнюю часть живота к позвоночнику, чтобы защитить поясницу от избыточного прогиба."
        ),
        "bakasana": AIPoseAnalysisData(
            technique: "Присядьте, поставьте ладони на пол на ширине плеч. Поместите колени как можно выше на трицепсы рук. Перенесите вес вперед и оторвите стопы от пола, балансируя на руках.",
            pros: ["Развивает невероятную силу рук, плеч и запястий", "Укрепляет глубокие мышцы кора и пресса", "Улучшает баланс и уверенность в возможностях тела"],
            cons: ["Синдром запястного канала", "Беременность", "Травмы запястий"],
            targetedMuscles: ["Трицепсы", "Передние дельты", "Кор", "Запястья"],
            aiTip: "Смотрите вперед перед собой на коврик, а не вниз на ладони. Взгляд определяет равновесие."
        ),
        "camel": AIPoseAnalysisData(
            technique: "Встаньте на колени на ширине бедер. Положите ладони на поясницу. На вдохе поднимите грудь и мягко прогнитесь назад. По возможности опустите руки на пятки.",
            pros: ["Раскрывает всю переднюю поверхность тела и грудь", "Растягивает глубокие сгибатели бедра", "Увеличивает гибкость и подвижность спины"],
            cons: ["Травмы шеи или поясницы", "Высокое или низкое давление"],
            targetedMuscles: ["Грудные", "Прямая мышца живота", "Сгибатели бедра", "Квадрицепсы"],
            aiTip: "Толкайте таз вперед, чтобы удерживать бедра вертикально над коленями. Берегите шею."
        ),
        "half_moon": AIPoseAnalysisData(
            technique: "Из положения стоя наклонитесь вперед, поставьте правую руку на пол. Поднимите левую ногу параллельно полу, развернув таз и грудную клетку влево. Левую руку вытяните вверх.",
            pros: ["Улучшает баланс на одной ноге и стабильность суставов", "Раскрывает грудь, плечевой пояс и таз", "Укрепляет бедра и лодыжки"],
            cons: ["Головокружение", "Недавние травмы колена или голеностопа"],
            targetedMuscles: ["Средняя ягодичная", "Заднее бедро", "Лодыжки", "Кор"],
            aiTip: "Активно сокращайте стопу поднятой ноги и напрягайте ее квадрицепс для стабилизации баланса."
        ),
        "pigeon": AIPoseAnalysisData(
            technique: "Из упора лежа проведите правое колено вперед к правому запястью, уложив голень на коврик. Левую ногу выпрямите назад. Выровняйте таз и плавно опустите корпус вперед.",
            pros: ["Глубоко раскрывает тазобедренные суставы и ягодичные мышцы", "Снимает глубокое психоэмоциональное напряжение", "Растягивает грушевидную мышцу"],
            cons: ["Травмы коленей", "Проблемы с крестцово-подвздошным суставом"],
            targetedMuscles: ["Большая ягодичная", "Грушевидная", "Поясничная", "Пах"],
            aiTip: "Следите за тем, чтобы таз не заваливался набок. Положите подушку под бедро согнутой ноги."
        )
    ]
    
    static func getCategoryAnalysis(for category: PoseCategory) -> AICategoryAnalysisData {
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        let isRussian = (language == "ru")
        
        if isRussian {
            return ruCategoryData[category] ?? defaultRuCategory()
        } else {
            return enCategoryData[category] ?? defaultEnCategory()
        }
    }
    
    private static func defaultEnCategory() -> AICategoryAnalysisData {
        AICategoryAnalysisData(
            description: "Practice category focused on enhancing your yoga journey.",
            technique: "Focus on breath synchronization and correct alignment in all poses.",
            posesOverview: "A curated sequence of poses representing this practice style."
        )
    }
    
    private static func defaultRuCategory() -> AICategoryAnalysisData {
        AICategoryAnalysisData(
            description: "Категория практики, направленная на совершенствование вашей йоги.",
            technique: "Фокусируйтесь на синхронизации дыхания и корректном выравнивании во всех асанах.",
            posesOverview: "Курируемая последовательность асан, представляющая данный стиль практики."
        )
    }
    
    private static let enCategoryData: [PoseCategory: AICategoryAnalysisData] = [
        .strength: AICategoryAnalysisData(
            description: "Strength yoga activates deep stabilizing muscle fibers, building a firm core and joint support using your own body weight. It fires up metabolism and improves overall physical endurance.",
            technique: "AI Technique Guidelines: Maintain control of your bandhas (pelvic floor and core locks), stabilize your hips and shoulders in weight-bearing planks. Keep a slow, steady breath; do not hold your breath during peak stress.",
            posesOverview: "Poses (Bridge, Warrior I & II, Boat, Plank, Chair, Crow) are designed to target explosive and static power in your arms, core, and legs."
        ),
        .flexibility: AICategoryAnalysisData(
            description: "Flexibility practices focus on safely extending joint range of motion, muscle elasticity, and dissolving physical blocks. According to AI tracking, it enhances blood circulation and repairs fascia.",
            technique: "AI Technique Guidelines: Allow your body to sink and lengthen on slow, complete exhalations. Avoid jerky movements or pushing through sharp pain. Use blocks or straps to maintain a flat back in folds.",
            posesOverview: "Poses (Cat-Cow, Cobra, Downward Dog, Seated Forward Fold, Seated Twist, Triangle, Camel, Pigeon) elongate the spine and release compression in the hip joints."
        ),
        .balance: AICategoryAnalysisData(
            description: "Balancing poses train your proprioception (sense of body position in space) and neuromuscular coordination. AI observations highlight the firing of foot arches and deep core muscles to stabilize the body.",
            technique: "AI Technique Guidelines: Lock your gaze on a single, stationary point (Drishti). Distribute weight equally across the triangle of your standing foot (big toe, pinky toe, heel). Keep your lower abdomen drawn in.",
            posesOverview: "Poses (Mountain, Tree, Crow, Half Moon) refine focus, build stabilizers in your lower body joints, and cultivate mental stillness."
        ),
        .restorative: AICategoryAnalysisData(
            description: "Restorative yoga triggers the parasympathetic nervous system, shifting the body into a state of 'rest and digest'. AI analysis registers immediate decreases in heart rate variance and stress markers.",
            technique: "AI Technique Guidelines: Surrender all muscular effort to gravity. Extend your exhalations to be twice as long as your inhalations. Ensure the body is fully warm and comfortable with bolsters.",
            posesOverview: "Poses (Child's Pose, Savasana) focus on deep relaxation, mental release, and integrating the benefits of the active workout."
        )
    ]
    
    private static let ruCategoryData: [PoseCategory: AICategoryAnalysisData] = [
        .strength: AICategoryAnalysisData(
            description: "Силовая йога активирует глубокие мышечные стабилизаторы, укрепляет мышечный корсет и суставы с использованием веса собственного тела. Она стимулирует метаболизм и развивает выносливость.",
            technique: "Рекомендации ИИ по технике: удерживайте бандхи (энергетические замки), стабилизируйте таз и плечевой пояс в силовых упорах. Дышите ровно, избегая задержек дыхания при высоком напряжении.",
            posesOverview: "Силовые асаны (Мост, Воин I и II, Лодка, Планка, Уткатасана, Бакасана) направлены на развитие взрывной и статической силы рук, кора и ног."
        ),
        .flexibility: AICategoryAnalysisData(
            description: "Практика на гибкость направлена на безопасное увеличение амплитуды движений в суставах, эластичность мышц и снятие блоков. ИИ отмечает ускорение кровотока и восстановление фасций.",
            technique: "Рекомендации ИИ по технике: растягивайтесь на медленном выдохе. Никогда не преодолевайте резкую боль. Используйте блоки или ремни для поддержания ровной осанки при глубоких наклонах.",
            posesOverview: "Асаны на растяжку (Кошка-Корова, Кобра, Собака мордой вниз, Наклон сидя, Скручивание, Треугольник, Прогиб Верблюда, Поза Голубя) вытягивают позвоночник и раскрывают бедра."
        ),
        .balance: AICategoryAnalysisData(
            description: "Балансировка развивает проприоцепцию (ощущение тела в пространстве) и межмышечную координацию. ИИ подчеркивает укрепление мелких мышц стоп и стабилизаторов кора.",
            technique: "Рекомендации ИИ по технике: найдите взглядом одну неподвижную точку. Равномерно распределяйте вес по четырем углам опорной стопы. Держите мышцы живота слегка подтянутыми.",
            posesOverview: "Асаны на равновесие (Тадасана, Поза Дерева, Бакасана, Полумесяц) развивают концентрацию внимания и укрепляют опорно-двигательный аппарат."
        ),
        .restorative: AICategoryAnalysisData(
            description: "Восстановительная йога переводит нервную систему в парасимпатический режим (отдых и пищеварение). ИИ фиксирует снижение кортизола и уровня стресса.",
            technique: "Рекомендации ИИ по технике: полностью расслабьте все мышцы. Удлиняйте выдохи по сравнению со вдохами. Используйте подушки и пледы, чтобы телу было максимально комфортно и тепло.",
            posesOverview: "Асаны для отдыха (Поза Ребенка, Шавасана) направлены на глубокую релаксацию, ментальную разгрузку и интеграцию пользы от активной практики."
        )
    ]
}

struct AICategoryAnalysisData: Hashable {
    let description: String
    let technique: String
    let posesOverview: String
}
