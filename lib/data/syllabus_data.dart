import '../models/exam_type.dart';
import '../models/syllabus_model.dart';

class SyllabusData {
  static List<SyllabusSubject> getSyllabus(ExamType examType) {
    if (examType == ExamType.psi) {
      return _getPsiSyllabus();
    } else {
      return _getConstableSyllabus();
    }
  }

  static List<SyllabusSubject> _getConstableSyllabus() {
    return [
      SyllabusSubject(
        id: 'const_bandharan',
        title: 'Indian Constitution',
        titleGujarati: 'ભારતીય બંધારણ અને રાજ્યવ્યવસ્થા',
        iconName: 'gavel',
        totalMarksWeightage: 15,
        mcqCount: 450,
        topics: [
          SyllabusTopic(
            id: 'c1',
            name: 'Preamble & Fundamental Rights',
            nameGujarati: 'આમુખ અને મૂળભૂત અધિકારો (કલમ 12 થી 35)',
            keyPoints: ['સમાનતાનો અધિકાર', 'સ્વતંત્રતાનો અધિકાર', 'બંધારણીય ઇલાજનો અધિકાર (Art 32)'],
            mcqCount: 150,
          ),
          SyllabusTopic(
            id: 'c2',
            name: 'Directive Principles & Fundamental Duties',
            nameGujarati: 'માર્ગદર્શક સિદ્ધાંતો અને મૂળભૂત ફરજો (Art 51A)',
            keyPoints: ['રાજ્યનીતિના માર્ગદર્શક સિદ્ધાંતો', '11 મૂળભૂત ફરજો'],
            mcqCount: 100,
          ),
          SyllabusTopic(
            id: 'c3',
            name: 'President, Governor & Parliament',
            nameGujarati: 'રાષ્ટ્રપતિ, રાજ્યપાલ, સંસદ અને વિધાનમંડળ',
            keyPoints: ['રાષ્ટ્રપતિની સત્તાઓ', 'રાજ્યપાલની નિમણૂક', 'લોકસભા અને રાજ્યસભાની રચના'],
            mcqCount: 120,
          ),
          SyllabusTopic(
            id: 'c4',
            name: 'Judiciary & Panchayati Raj',
            nameGujarati: 'ન્યાયપાલિકા અને પંચાયતી રાજ (73મો & 74મો સુધારો)',
            keyPoints: ['સુપ્રીમ કોર્ટ', 'હાઇકોર્ટ', 'ત્રિસ્તરીય પંચાયતી રાજ'],
            mcqCount: 80,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_kaydo',
        title: 'Criminal Laws & Police Procedures',
        titleGujarati: 'કાયદો અને ફોજદારી કાર્યવાહી (IPC, CrPC, પુરાવા)',
        iconName: 'security',
        totalMarksWeightage: 20,
        mcqCount: 620,
        topics: [
          SyllabusTopic(
            id: 'k1',
            name: 'Indian Penal Code (IPC) / BNS Basics',
            nameGujarati: 'IPC / ભારતીય ન્યાય સંહિતાની મહત્વની કલમો',
            keyPoints: ['ગુનાહિત ષડયંત્ર', 'માનવ શરીર સામેના ગુના (હત્યા, ઇજા)', 'ચોરી, લૂંટ અને ધાડ'],
            mcqCount: 220,
          ),
          SyllabusTopic(
            id: 'k2',
            name: 'Criminal Procedure Code (CrPC) / BNSS',
            nameGujarati: 'CrPC / ભારતીય નાગરિક સુરક્ષા સંહિતા',
            keyPoints: ['FIR દાખલ કરવાની પ્રક્રિયા (કલમ 154)', 'ધરપકડના નિયમો', 'જામીનલાયક અને બિનજામીનલાયક ગુના'],
            mcqCount: 180,
          ),
          SyllabusTopic(
            id: 'k3',
            name: 'Indian Evidence Act / BSA',
            nameGujarati: 'ઇન્ડિયન એવિડન્સ એક્ટ / ભારતીય સાક્ષ્ય અધિનિયમ',
            keyPoints: ['મૌખિક અને દસ્તાવેજી પુરાવા', 'સાક્ષીઓની જુબાની', 'બર્ડન ઓફ પ્રૂફ'],
            mcqCount: 120,
          ),
          SyllabusTopic(
            id: 'k4',
            name: 'Gujarat Police Act & Prohibition Act',
            nameGujarati: 'ગુજરાત પોલીસ એક્ટ અને દારૂબંધી અધિનિયમ',
            keyPoints: ['પોલીસ અધિકારીઓની ફરજો', 'જાહેર વ્યવસ્થા જાળવણી', 'દારૂબંધી કાયદાની જોગવાઈઓ'],
            mcqCount: 100,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_reasoning',
        title: 'Reasoning & Mental Ability',
        titleGujarati: 'તાર્કિક કસોટીઓ અને માનસિક ક્ષમતા',
        iconName: 'psychology',
        totalMarksWeightage: 20,
        mcqCount: 480,
        topics: [
          SyllabusTopic(
            id: 'r1',
            name: 'Series & Coding-Decoding',
            nameGujarati: 'સંખ્યા / અક્ષર શ્રેણી અને કોડિંગ-ડિકોડિંગ',
            keyPoints: ['સંખ્યા શ્રેણી', 'આલ્ફાબેટ શ્રેણી', 'ચાઈનીઝ કોડિંગ'],
            mcqCount: 130,
          ),
          SyllabusTopic(
            id: 'r2',
            name: 'Blood Relations & Direction Sense',
            nameGujarati: 'લોહીના સંબંધો અને દિશા-અંતર',
            keyPoints: ['કૌટુંબિક સંબંધોનું પૃથક્કરણ', 'દિશા અને ખૂણા ગણતરી'],
            mcqCount: 110,
          ),
          SyllabusTopic(
            id: 'r3',
            name: 'Seating Arrangement & Ranking',
            nameGujarati: 'બેઠક વ્યવસ્થા અને ક્રમ કસોટી',
            keyPoints: ['ગોળાકાર અને રેખીય બેઠક વ્યવસ્થા', 'ડાબે-જમણે ક્રમ નિર્ધારણ'],
            mcqCount: 120,
          ),
          SyllabusTopic(
            id: 'r4',
            name: 'Syllogism & Venn Diagrams',
            nameGujarati: 'તાર્કિક વિધાનો અને વેન આકૃતિઓ',
            keyPoints: ['વિધાન-તારણ', 'વેન ડાયાગ્રામ આધારિત પ્રશ્નો'],
            mcqCount: 120,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_science',
        title: 'General Science & Technology',
        titleGujarati: 'સામાન્ય વિજ્ઞાન અને ટેકનોલોજી',
        iconName: 'science',
        totalMarksWeightage: 15,
        mcqCount: 380,
        topics: [
          SyllabusTopic(
            id: 's1',
            name: 'Biology & Human Health',
            nameGujarati: 'જીવવિજ્ઞાન, માનવ શરીર અને રોગો',
            keyPoints: ['પાચનતંત્ર, શ્વસનતંત્ર, રુધિરાભિસરણ તંત્ર', 'વિટામિન્સ, ખનિજો અને પોષકતત્વો', 'રોગો અને રસીકરણ'],
            mcqCount: 140,
          ),
          SyllabusTopic(
            id: 's2',
            name: 'Physics & Everyday Science',
            nameGujarati: 'ભૌતિક વિજ્ઞાન અને દૈનિક જીવન',
            keyPoints: ['પ્રકાશ, અવાજ અને ગરમી', 'બળ, ગતિ અને ગુરુત્વાકર્ષણ', 'વીજળી અને ચુંબકત્વ'],
            mcqCount: 130,
          ),
          SyllabusTopic(
            id: 's3',
            name: 'ISRO, DRDO & Defense Tech',
            nameGujarati: 'ભારતીય અવકાશ સંશોધન (ISRO) & સંરક્ષણ',
            keyPoints: ['ચંદ્રયાન, આદિત્ય-L1', 'મિસાઇલ સિસ્ટમ્સ (અગ્નિ, બ્રહ્મોસ)', 'સાયબર સુરક્ષા'],
            mcqCount: 110,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_history',
        title: 'Gujarat History & Cultural Heritage',
        titleGujarati: 'ગુજરાતનો ઇતિહાસ અને સાંસ્કૃતિક વારસો',
        iconName: 'account_balance',
        totalMarksWeightage: 15,
        mcqCount: 550,
        topics: [
          SyllabusTopic(
            id: 'h1',
            name: 'Ancient & Medieval Gujarat',
            nameGujarati: 'પ્રાચીન અને મધ્યકાલીન ગુજરાત',
            keyPoints: ['મૈત્રક વંશ, ચાવડા વંશ', 'સોલંકી યુગ (સુવર્ણ યુગ - સિદ્ધરાજ જયસિંહ)', 'વાઘેલા વંશ અને સુલતાનત કાળ'],
            mcqCount: 160,
          ),
          SyllabusTopic(
            id: 'h2',
            name: 'Freedom Movement in Gujarat',
            nameGujarati: 'ગુજરાતમાં આઝાદીની ચળવળ',
            keyPoints: ['દાંડી કૂચ, ધરાસણા સત્યાગ્રહ', 'બારડોલી સત્યાગ્રહ (સરદાર પટેલ)', 'મહાગુજરાત આંદોલન (ઇન્દુલાલ યાજ્ઞિક)'],
            mcqCount: 140,
          ),
          SyllabusTopic(
            id: 'h3',
            name: 'Fairs, Festivals & Architecture',
            nameGujarati: 'મેળાઓ, ઉત્સવો, કલા અને સ્થાપત્ય',
            keyPoints: ['તરણેતરનો મેળો, ભવનાથનો મેળો, શામળાજી મેળો', 'રાણકી વાવ (પાટણ)', 'મોઢેરાનું સૂર્યમંદિર, સોમનાથ'],
            mcqCount: 150,
          ),
          SyllabusTopic(
            id: 'h4',
            name: 'Literature & Great Personalities',
            nameGujarati: 'સાહિત્યકારો અને મહાન વિભૂતિઓ',
            keyPoints: ['નરસિંહ મહેતા, મીરાંબાઈ, પ્રેમાનંદ', 'નર્મદ, દલપતરામ, મેઘાણી', 'મહાત્મા ગાંધી, સરદાર પટેલ'],
            mcqCount: 100,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_geography',
        title: 'Geography of Gujarat & India',
        titleGujarati: 'ગુજરાત અને ભારતની ભૂગોળ',
        iconName: 'public',
        totalMarksWeightage: 15,
        mcqCount: 420,
        topics: [
          SyllabusTopic(
            id: 'g1',
            name: 'Rivers, Mountains & Coastline',
            nameGujarati: 'નદીઓ, પર્વતો અને દરિયાકિનારો',
            keyPoints: ['નર્મદા, તાપી, સાબરમતી, મહી', 'ગિરનાર, પાવાગઢ, ચોટીલા', '1600 કિમી દરિયાકિનારો, અખાતો અને બંદરો'],
            mcqCount: 140,
          ),
          SyllabusTopic(
            id: 'g2',
            name: 'Districts & Special Features',
            nameGujarati: '33 જિલ્લાઓ અને તેની વિશેષતાઓ',
            keyPoints: ['કચ્છ જિલ્લો (સૌથી મોટો)', 'ડાંગ જિલ્લો (સૌથી નાનો)', 'ખનીજો, ઉદ્યોગો અને મુખ્ય મથકો'],
            mcqCount: 150,
          ),
          SyllabusTopic(
            id: 'g3',
            name: 'National Parks & Wildlife',
            nameGujarati: 'રાષ્ટ્રીય ઉદ્યાનો અને અભયારણ્યો',
            keyPoints: ['ગીર રાષ્ટ્રીય ઉદ્યાન (એશિયાટિક સિંહ)', 'વેળાવદર (કાળિયાર)', 'મરીન નેશનલ પાર્ક (જામનગર)', 'નળ સરોવર'],
            mcqCount: 130,
          ),
        ],
      ),
    ];
  }

  static List<SyllabusSubject> _getPsiSyllabus() {
    return [
      SyllabusSubject(
        id: 'psi_paper1_law',
        title: 'PSI Paper 1: Major Acts & Legal Framework',
        titleGujarati: 'PSI પેપર ૧: ફોજદારી કાયદા (IPC, CrPC, પુરાવા)',
        iconName: 'gavel',
        totalMarksWeightage: 100,
        mcqCount: 850,
        topics: [
          SyllabusTopic(
            id: 'pl1',
            name: 'IPC (Indian Penal Code) In-depth',
            nameGujarati: 'IPC કલમોનું ઊંડાણપૂર્વક વિશ્લેષણ',
            keyPoints: ['સામાન્ય અપવાદો (કલમ 76 થી 106)', 'માનવ શરીર સામેના ગુના', 'મિલકત સામેના ગુના', 'દસ્તાવેજી છેતરપિંડી'],
            mcqCount: 300,
          ),
          SyllabusTopic(
            id: 'pl2',
            name: 'CrPC (Code of Criminal Procedure)',
            nameGujarati: 'CrPC ફોજદારી કાર્યવાહી સંહિતા',
            keyPoints: ['તપાસ અને પૂછપરછ પ્રક્રિયા', 'ધરપકડ, જડતી અને વોરન્ટ', 'ચાર્જશીટ અને અદાલતી કેસ ચલાવવાની રીત'],
            mcqCount: 250,
          ),
          SyllabusTopic(
            id: 'pl3',
            name: 'Indian Evidence Act',
            nameGujarati: 'ભારતીય પુરાવા અધિનિયમ',
            keyPoints: ['પ્રસ્તુત હકીકતો (Relevance)', 'કબૂલાત (Confession)', 'નિષ્ણાતનો અભિપ્રાય', 'દસ્તાવેજી પુરાવાની વિશ્વસનીયતા'],
            mcqCount: 180,
          ),
          SyllabusTopic(
            id: 'pl4',
            name: 'Special Acts: Anti-Corruption & Cyber Crime',
            nameGujarati: 'વિશેષ કાયદા: ભ્રષ્ટાચાર નિવારણ & સાયબર કાયદો',
            keyPoints: ['ભ્રષ્ટાચાર નિવારણ અધિનિયમ 1988', 'IT એક્ટ 2000 (સાયબર ગુના)', 'SC/ST અત્યાચાર નિવારણ ધારો'],
            mcqCount: 120,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'psi_paper2_lang',
        title: 'PSI Paper 2: Gujarati & English Languages',
        titleGujarati: 'PSI પેપર ૨: ગુજરાતી અને અંગ્રેજી ભાષા',
        iconName: 'translate',
        totalMarksWeightage: 100,
        mcqCount: 600,
        topics: [
          SyllabusTopic(
            id: 'plg1',
            name: 'Gujarati Grammar & Vocabulary',
            nameGujarati: 'ગુજરાતી વ્યાકરણ અને શબ્દભંડોળ',
            keyPoints: ['સંધિ, સમાસ, છંદ, અલંકાર', 'રૂઢિપ્રયોગો અને કહેવતો', 'સમાનાર્થી અને વિરોધી શબ્દો', 'શબ્દસમૂહ માટે એક શબ્દ'],
            mcqCount: 300,
          ),
          SyllabusTopic(
            id: 'plg2',
            name: 'English Grammar & Comprehension',
            nameGujarati: 'અંગ્રેજી વ્યાકરણ અને ભાષા પ્રભુત્વ',
            keyPoints: ['Tenses, Active-Passive Voice', 'Direct-Indirect Speech', 'Prepositions & Articles', 'Synonyms & Antonyms'],
            mcqCount: 300,
          ),
        ],
      ),
      SyllabusSubject(
        id: 'psi_paper3_gs',
        title: 'PSI Paper 3: General Studies & Constitution',
        titleGujarati: 'PSI પેપર ૩: સામાન્ય અભ્યાસ અને બંધારણ',
        iconName: 'public',
        totalMarksWeightage: 100,
        mcqCount: 750,
        topics: [
          SyllabusTopic(
            id: 'pgs1',
            name: 'Constitution of India Advanced',
            nameGujarati: 'ભારતીય બંધારણ એડવાન્સ્ડ',
            keyPoints: ['મૂળભૂત હકો અને કટોકટીની જોગવાઈઓ', 'સંસદીય વિશેષાધિકારો', 'બંધારણીય સુધારાઓ (42મો, 44મો, 101મો, 103મો)'],
            mcqCount: 250,
          ),
          SyllabusTopic(
            id: 'pgs2',
            name: 'History, Geography & Culture',
            nameGujarati: 'ઇતિહાસ, ભૂગોળ અને વારસો',
            keyPoints: ['ભારત અને ગુજરાતનો આધુનિક ઇતિહાસ', 'ભૌતિક અને આર્થિક ભૂગોળ', 'સાંસ્કૃતિક વારસો'],
            mcqCount: 250,
          ),
          SyllabusTopic(
            id: 'pgs3',
            name: 'Current Affairs & Logical Reasoning',
            nameGujarati: 'વર્તમાન પ્રવાહો અને તાર્કિક ક્ષમતા',
            keyPoints: ['રાષ્ટ્રીય અને આંતરરાષ્ટ્રીય ઘટનાઓ', 'બજેટ અને આર્થિક સમીક્ષા', 'એડવાન્સ્ડ ડેટા ઇન્ટરપ્રિટેશન'],
            mcqCount: 250,
          ),
        ],
      ),
    ];
  }
}
