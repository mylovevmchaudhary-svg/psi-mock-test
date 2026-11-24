import '../models/quiz_model.dart';

class QuestionBankGenerator {
  /// Generates a full MockTest with 200 MCQs and 180 minutes duration
  static MockTest generateMockTest({
    required String examCategoryId,
    required String examTitle,
    required int testNumber,
  }) {
    final testId = '${examCategoryId}_$testNumber';
    final isFree = testNumber <= 3;

    final questions = <Question>[];

    // 1. Indian Constitution (30 MCQs: 1 to 30)
    for (int i = 1; i <= 30; i++) {
      questions.add(_generateConstitutionQuestion(testNumber, i));
    }

    // 2. Criminal Laws & Police Acts (35 MCQs: 31 to 65)
    for (int i = 1; i <= 35; i++) {
      questions.add(_generateLawQuestion(testNumber, 30 + i));
    }

    // 3. Gujarat History & Heritage (25 MCQs: 66 to 90)
    for (int i = 1; i <= 25; i++) {
      questions.add(_generateHistoryQuestion(testNumber, 65 + i));
    }

    // 4. Gujarat & India Geography (25 MCQs: 91 to 115)
    for (int i = 1; i <= 25; i++) {
      questions.add(_generateGeographyQuestion(testNumber, 90 + i));
    }

    // 5. Reasoning & Mental Ability (35 MCQs: 116 to 150)
    for (int i = 1; i <= 35; i++) {
      questions.add(_generateReasoningQuestion(testNumber, 115 + i));
    }

    // 6. Quantitative Aptitude & Maths (20 MCQs: 151 to 170)
    for (int i = 1; i <= 20; i++) {
      questions.add(_generateMathQuestion(testNumber, 150 + i));
    }

    // 7. General Science (15 MCQs: 171 to 185)
    for (int i = 1; i <= 15; i++) {
      questions.add(_generateScienceQuestion(testNumber, 170 + i));
    }

    // 8. Current Affairs & Police GK (15 MCQs: 186 to 200)
    for (int i = 1; i <= 15; i++) {
      questions.add(_generateCurrentAffairsQuestion(testNumber, 185 + i));
    }

    return MockTest(
      id: testId,
      title: '$examTitle - સંપૂર્ણ મોક ટેસ્ટ #$testNumber',
      description: isFree
          ? '🌟 ફ્રી મોક ટેસ્ટ (200 પ્રશ્નો • 180 મિનિટ • નેગેટિવ માર્કિંગ 0.25)'
          : '🔒 પ્રીમિયમ ટેસ્ટ #$testNumber (એડ જોઈને અથવા 10 કોઈન્સથી અનલોક કરો)',
      category: isFree ? 'Free Mock' : 'Premium Mock',
      durationMinutes: 180,
      positiveMarksPerQuestion: 1.0,
      negativeMarksPerQuestion: 0.25,
      questions: questions,
    );
  }

  // 1. Indian Constitution Generator
  static Question _generateConstitutionQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'ભારતના બંધારણના કયા અનુચ્છેદ મુજબ કાયદા સમક્ષ સમાનતાનો અધિકાર આપવામાં આવ્યો છે?',
        'opts': ['અનુચ્છેદ 14', 'અનુચ્છેદ 19', 'અનુચ્છેદ 21', 'અનુચ્છેદ 32'],
        'ans': 0,
        'exp': 'અનુચ્છેદ 14 કાયદા સમક્ષ સમાનતા અને કાયદાઓનું સમાન રક્ષણ સુનિશ્ચિત કરે છે.',
      },
      {
        'q': 'ભારતના રાષ્ટ્રપતિ પર મહાભિયોગ (Impeachment) ચલાવવાની જોગવાઈ કયા અનુચ્છેદમાં છે?',
        'opts': ['અનુચ્છેદ 52', 'અનુચ્છેદ 61', 'અનુચ્છેદ 72', 'અનુચ્છેદ 123'],
        'ans': 1,
        'exp': 'અનુચ્છેદ 61 હેઠળ સંસદના કોઈપણ ગૃહ દ્વારા રાષ્ટ્રપતિ પર મહાભિયોગ ચલાવી શકાય છે.',
      },
      {
        'q': 'નાણાકીય કટોકટી (Financial Emergency) ની જોગવાઈ બંધારણના કયા અનુચ્છેદમાં છે?',
        'opts': ['અનુચ્છેદ 352', 'અનુચ્છેદ 356', 'અનુચ્છેદ 360', 'અનુચ્છેદ 368'],
        'ans': 2,
        'exp': 'અનુચ્છેદ 360 હેઠળ ભારતમાં આજ સુધી એક પણ વાર નાણાકીય કટોકટી લાગુ કરવામાં આવી નથી.',
      },
      {
        'q': 'ભારતીય બંધારણમાં મૂળભૂત ફરજો (Fundamental Duties) કયા બંધારણીય સુધારા દ્વારા ઉમેરાઈ?',
        'opts': ['42મો સુધારો (1976)', '44મો સુધારો (1978)', '73મો સુધારો (1992)', '86મો સુધારો (2002)'],
        'ans': 0,
        'exp': 'સ્વર્ણ સિંહ સમિતિની ભલામણથી 42મા સુધારા દ્વારા ભાગ 4A અને અનુચ્છેદ 51A ઉમેરાયા હતા.',
      },
      {
        'q': 'બંધારણ સભાના કાયમી અધ્યક્ષ તરીકે કોની પસંદગી કરવામાં આવી હતી?',
        'opts': ['ડૉ. સચ્ચિદાનંદ સિન્હા', 'ડૉ. રાજેન્દ્ર પ્રસાદ', 'ડૉ. બી.આર. આંબેડકર', 'જવાહરલાલ નહેરુ'],
        'ans': 1,
        'exp': '11 ડિસેમ્બર 1946 ના રોજ ડૉ. રાજેન્દ્ર પ્રસાદને બંધારણ સભાના કાયમી અધ્યક્ષ ચૂંટવામાં આવ્યા હતા.',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'c_${testNum}_$qNum',
      subject: 'ભારતીય બંધારણ (Constitution)',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }

  // 2. Criminal Laws Generator
  static Question _generateLawQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'IPC કલમ 302 મુજબ કયા ગુના માટે સજાની જોગવાઈ છે?',
        'opts': ['ખૂન (Murder) ની સજા', 'ચોરીની સજા', 'બળાત્કારની સજા', 'માનહાનિની સજા'],
        'ans': 0,
        'exp': 'કલમ 300 માં ખૂનની વ્યાખ્યા અને કલમ 302 માં આજીવન કેદ અથવા ફાંસીની સજાની જોગવાઈ છે.',
      },
      {
        'q': 'CrPC ની કલમ 154 શાની સાથે સંબંધિત છે?',
        'opts': ['વોરંટ વગર ધરપકડ', 'પ્રથમ માહિતી અહેવાલ (FIR)', 'પંચનામું', 'જામીન અરજી'],
        'ans': 1,
        'exp': 'કોગ્નિઝેબલ ગુનામાં કલમ 154 હેઠળ FIR નોંધવી પોલીસ માટે ફરજિયાત છે.',
      },
      {
        'q': 'ઇન્ડિયન એવિડન્સ એક્ટ મુજબ ડાઈંગ ડેકલેરેશન (મરણોન્મુખ નિવેદન) કઈ કલમ હેઠળ ગ્રાહ્ય છે?',
        'opts': ['કલમ 25', 'કલમ 27', 'કલમ 32(1)', 'કલમ 45'],
        'ans': 2,
        'exp': 'કલમ 32(1) હેઠળ મરનાર વ્યક્તિનું પોતાના મૃત્યુના કારણ અંગેનું નિવેદન અદાલતમાં પુરાવા તરીકે માન્ય છે.',
      },
      {
        'q': 'ગુજરાત પોલીસ એક્ટ મુજબ જાહેર રસ્તા પર ઉપદ્રવ કરનાર સામે પગલાં લેવાની સત્તા કોને છે?',
        'opts': ['તમામ પોલીસ અધિકારીઓ', 'માત્ર ડીવાયએસપી', 'માત્ર કલેક્ટર', 'માત્ર હોમગાર્ડ'],
        'ans': 0,
        'exp': 'ગુજરાત પોલીસ એક્ટ જાહેર વ્યવસ્થા અને કાયદો જાળવવા માટે પોલીસ અધિકારીઓને વિશેષ સત્તા આપે છે.',
      },
      {
        'q': 'IPC મુજબ "ગેરકાયદેસર મંડળી" (Unlawful Assembly) માં ઓછામાં ઓછી કેટલી વ્યક્તિઓ હોવી જોઈએ?',
        'opts': ['2 વ્યક્તિ', '3 વ્યક્તિ', '5 કે તેથી વધુ વ્યક્તિ', '10 વ્યક્તિ'],
        'ans': 2,
        'exp': 'કલમ 141 મુજબ સમાન ઈરાદો ધરાવતી 5 કે તેથી વધુ વ્યક્તિઓનું મંડળ ગેરકાયદે મંડળી ગણાય છે.',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'law_${testNum}_$qNum',
      subject: 'કાયદો (Criminal Law & Police Acts)',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }

  // 3. History Question Generator
  static Question _generateHistoryQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'સિંધુ ખીણની સભ્યતાનું કયું નગર વિશ્વનું સૌથી જૂનું વોટર હાર્વેસ્ટિંગ સિસ્ટમ ધરાવે છે?',
        'opts': ['લોથલ', 'ધોળાવીરા (ખદીરબેટ)', 'રંગપુર', 'રોઝડી'],
        'ans': 1,
        'exp': 'કચ્છમાં આવેલું ધોળાવીરા યુનેસ્કો વર્લ્ડ હેરિટેજ સાઈટ છે અને ઉત્કૃષ્ટ જળ વ્યવસ્થાપન માટે જાણીતું છે.',
      },
      {
        'q': 'ગુજરાતમાં "સહસ્ત્રલિંગ તળાવ" અને "રાણકી વાવ" નું નિર્માણ કયા વંશના શાસનકાળ દરમિયાન થયું?',
        'opts': ['મૈત્રક વંશ', 'ચાવડા વંશ', 'સોલંકી વંશ', 'વાઘેલા વંશ'],
        'ans': 2,
        'exp': 'સોલંકી વંશના સુવર્ણકાળમાં સિદ્ધરાજ જયસિંહ અને રાણી ઉદયમતી દ્વારા આ ઐતિહાસિક સ્થાપત્યો બંધાયા હતા.',
      },
      {
        'q': 'મહાત્મા ગાંધીજીએ 1930 માં કઈ ઐતિહાસિક લડત માટે સાબરમતીથી દાંડી યાત્રા શરૂ કરી હતી?',
        'opts': ['ખેડા સત્યાગ્રહ', 'અસહકાર આંદોલન', 'મીઠાનો સત્યાગ્રહ (સવિનય કાનૂનભંગ)', 'ભારત છોડો આંદોલન'],
        'ans': 2,
        'exp': '12 માર્ચ 1930 ના રોજ 78 સાથીઓ સાથે ગાંધીજીએ દાંડી કૂચ શરૂ કરી 6 એપ્રિલે મીઠાનો કાયદો તોડ્યો હતો.',
      },
      {
        'q': 'ગુજરાતના કયા મહાન ક્રાંતિકારીને "ભારતીય અશાંતિના પિતા" ના સાથી અને "ઇન્ડિયા હાઉસ" ના સ્થાપક ગણવામાં આવે છે?',
        'opts': ['શ્યામજી કૃષ્ણ વર્મા', 'સરદાર અજીત સિંહ', 'ચંદ્રશેખર આઝાદ', 'લાલા લજપત રાય'],
        'ans': 0,
        'exp': 'કચ્છના માંડવીના વતની શ્યામજી કૃષ્ણ વર્માએ લંડનમાં ઇન્ડિયા હાઉસ અને ધ સોશિયોલોજિસ્ટ શરૂ કર્યું હતું.',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'hist_${testNum}_$qNum',
      subject: 'ગુજરાત અને ભારતનો ઇતિહાસ',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }

  // 4. Geography Question Generator
  static Question _generateGeographyQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'ગુજરાત રાજ્યનો દરિયાકિનારો આશરે કેટલા કિલોમીટર લાંબો છે જે દેશમાં સૌથી લાંબો છે?',
        'opts': ['1200 કિમી', '1600 કિમી', '1850 કિમી', '2100 કિમી'],
        'ans': 1,
        'exp': 'ગુજરાત પાસે આશરે 1600 કિમી (990 માઈલ) લાંબો દરિયાકિનારો છે જે ભારતના કુલ દરિયાકિનારાના 24% છે.',
      },
      {
        'q': 'એશિયાટિક સિંહો (Gir Lions) માટેનું એકમાત્ર વસવાટ "ગીર રાષ્ટ્રીય ઉદ્યાન" કયા વર્ષમાં સ્થપાયું?',
        'opts': ['1965', '1975', '1982', '1990'],
        'ans': 1,
        'exp': 'ગીર સેન્ચ્યુરી 1965 માં અને ગીર નેશનલ પાર્ક 1975 માં ઘોષિત કરવામાં આવ્યું હતું.',
      },
      {
        'q': 'નર્મદા નદી પર આવેલો "સરદાર સરોવર બંધ" ગુજરાતના કયા જિલ્લામાં આવેલો છે?',
        'opts': ['ભરૂચ', 'નર્મદા (કેવડિયા)', 'વડોદરા', 'છોટા ઉદેપુર'],
        'ans': 1,
        'exp': 'નર્મદા જિલ્લાના કેવડિયા ખાતે સરદાર સરોવર ડેમ અને સ્ટેચ્યુ ઓફ યુનિટી આવેલા છે.',
      },
      {
        'q': 'ગુજરાતમાં સૌથી વધુ વિસ્તાર ધરાવતો જિલ્લો કયો છે?',
        'opts': ['બનાસકાંઠા', 'કચ્છ', 'જામનગર', 'સુરત'],
        'ans': 1,
        'exp': 'કચ્છ જિલ્લો 45,674 ચોરસ કિમી ક્ષેત્રફળ સાથે ગુજરાત અને ભારતનો સૌથી મોટો જિલ્લો છે.',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'geo_${testNum}_$qNum',
      subject: 'ગુજરાત અને ભારતની ભૂગોળ',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }

  // 5. Reasoning Generator
  static Question _generateReasoningQuestion(int testNum, int qNum) {
    int start = (testNum * 3) + (qNum % 7) + 2;
    int diff = 4 + (qNum % 3);
    int n1 = start;
    int n2 = n1 + diff;
    int n3 = n2 + diff;
    int n4 = n3 + diff;
    int ans = n4 + diff;

    return Question(
      id: 'reas_${testNum}_$qNum',
      subject: 'તાર્કિક કસોટી (Reasoning)',
      questionText: 'પ્રશ્ન $qNum. નીચે આપેલી શ્રેણી પૂર્ણ કરો: $n1, $n2, $n3, $n4, ?',
      options: [
        'A. ${ans - 2}',
        'B. $ans',
        'C. ${ans + 2}',
        'D. ${ans + 4}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: 1,
      explanation: 'આ શ્રેણીમાં દરેક પદ વચ્ચે +$diff નો સરખો તફાવત છે: $n4 + $diff = $ans.',
    );
  }

  // 6. Maths Question Generator
  static Question _generateMathQuestion(int testNum, int qNum) {
    int principal = 5000 + (testNum * 200) + (qNum * 50);
    int rate = 10;
    int time = 2;
    int interest = (principal * rate * time) ~/ 100;

    return Question(
      id: 'math_${testNum}_$qNum',
      subject: 'સામાન્ય ગણિત (Mathematics)',
      questionText: 'પ્રશ્ન $qNum. રૂ. $principal નું વાર્ષિક $rate% લેખે $time વર્ષનું સાદું વ્યાજ (Simple Interest) કેટલું થાય?',
      options: [
        'A. રૂ. ${interest - 100}',
        'B. રૂ. $interest',
        'C. રૂ. ${interest + 100}',
        'D. રૂ. ${interest + 200}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: 1,
      explanation: 'સૂત્ર: SI = (P * R * T) / 100 = ($principal * $rate * $time) / 100 = રૂ. $interest.',
    );
  }

  // 7. Science Question Generator
  static Question _generateScienceQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'સૂર્યપ્રકાશમાંથી માનવ શરીરને કયું વિટામિન કુદરતી રીતે પ્રાપ્ત થાય છે?',
        'opts': ['વિટામિન A', 'વિટામિન B', 'વિટામિન C', 'વિટામિન D'],
        'ans': 3,
        'exp': 'વિટામિન D હાડકાંના વિકાસ માટે જરૂરી છે અને તે ત્વચા સૂર્યના અલ્ટ્રાવાયોલેટ કિરણોના સંપર્કમાં આવતા બનાવે છે.',
      },
      {
        'q': 'માનવ રક્તનું સામાન્ય pH મૂલ્ય કેટલું હોય છે?',
        'opts': ['6.4', '7.4', '8.4', '5.4'],
        'ans': 1,
        'exp': 'માનવ લોહી સહેજ આલ્કલાઇન (બેઝિક) હોય છે અને તેનું સામાન્ય pH લગભગ 7.35 થી 7.45 વચ્ચે હોય છે.',
      },
      {
        'q': 'પાણીનું રાસાયણિક સૂત્ર (Chemical Formula) શું છે?',
        'opts': ['CO2', 'H2O', 'NaCl', 'H2SO4'],
        'ans': 1,
        'exp': 'પાણી હાઇડ્રોજનના 2 અણુ અને ઓક્સિજનના 1 અણુથી બનેલું સંયોજન છે (H2O).',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'sci_${testNum}_$qNum',
      subject: 'સામાન્ય વિજ્ઞાન (General Science)',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }

  // 8. Current Affairs Question Generator
  static Question _generateCurrentAffairsQuestion(int testNum, int qNum) {
    final pool = [
      {
        'q': 'ગુજરાત પોલીસમાં ઇમરજન્સી હેલ્પલાઇન નંબર તરીકે સમગ્ર રાજ્યમાં કયો નંબર કાર્યરત છે?',
        'opts': ['100', '108', '112', '181'],
        'ans': 2,
        'exp': 'સમગ્ર ભારતમાં ઇમરજન્સી રિસ્પોન્સ સપોર્ટ સિસ્ટમ (ERSS) હેઠળ સિંગલ ઇમરજન્સી નંબર 112 કાર્યરત છે.',
      },
      {
        'q': 'મહિલા સુરક્ષા અને કાઉન્સેલિંગ માટે ગુજરાતમાં કઈ વિશિષ્ટ હેલ્પલાઇન કાર્યરત છે?',
        'opts': ['1098 (ચાઇલ્ડ લાઇન)', '181 (અભયમ હેલ્પલાઇન)', '108', '1930 (સાયબર ફ્રોડ)'],
        'ans': 1,
        'exp': '181 અભયમ હેલ્પલાઇન પીડિત મહિલાઓને સ્થળ પર તાત્કાલિક બચાવ અને સલાહ પૂરી પાડે છે.',
      },
      {
        'q': 'સાયબર ક્રાઈમ અને ઓનલાઇન નાણાકીય છેતરપિંડીની તાત્કાલિક ફરિયાદ માટે કયો રાષ્ટ્રીય હેલ્પલાઇન નંબર છે?',
        'opts': ['100', '112', '1930', '1091'],
        'ans': 2,
        'exp': 'ગૃહ મંત્રાલય દ્વારા સાયબર નાણાકીય છેતરપિંડી રોકવા માટે 1930 હેલ્પલાઇન શરૂ કરવામાં આવી છે.',
      },
    ];

    final template = pool[(testNum + qNum) % pool.length];
    return Question(
      id: 'ca_${testNum}_$qNum',
      subject: 'વર્તમાન પ્રવાહો અને પોલીસ વહીવટ',
      questionText: 'પ્રશ્ન $qNum. ${template['q']}',
      options: [
        'A. ${(template['opts'] as List)[0]}',
        'B. ${(template['opts'] as List)[1]}',
        'C. ${(template['opts'] as List)[2]}',
        'D. ${(template['opts'] as List)[3]}',
        'E. પ્રયાસ કરેલ નથી (Not Attempted)',
      ],
      correctOptionIndex: template['ans'] as int,
      explanation: template['exp'] as String,
    );
  }
}
