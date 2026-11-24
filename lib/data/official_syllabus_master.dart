/// Official Syllabus Master Data for Gujarat Police PSI and LRD / Constable
/// Version-controlled, immutable master definition matching official government notifications.
/// Used for idempotent Firestore seeding and runtime validation.

class ExamMaster {
  final String examId;
  final String examCode;
  final String examName;
  final String description;
  final int totalQuestions;
  final int totalMarks;
  final int durationMinutes;
  final double negativeMarking;
  final List<SubjectMaster> subjects;

  const ExamMaster({
    required this.examId,
    required this.examCode,
    required this.examName,
    required this.description,
    required this.totalQuestions,
    required this.totalMarks,
    required this.durationMinutes,
    required this.negativeMarking,
    required this.subjects,
  });

  Map<String, dynamic> toMap() => {
    'id': examId,
    'exam_id': examId,
    'exam_code': examCode,
    'title': examName,
    'name': examName,
    'description': description,
    'total_questions': totalQuestions,
    'total_marks': totalMarks,
    'duration_minutes': durationMinutes,
    'negative_marks': negativeMarking,
    'negative_marking': negativeMarking,
  };
}

class SubjectMaster {
  final String subjectId;
  final String examId;
  final String subjectName;
  final int subjectOrder;
  final int officialMarks;
  final int practiceQuestionCount;
  final List<TopicMaster> topics;

  const SubjectMaster({
    required this.subjectId,
    required this.examId,
    required this.subjectName,
    required this.subjectOrder,
    required this.officialMarks,
    required this.practiceQuestionCount,
    required this.topics,
  });

  Map<String, dynamic> toMap() => {
    'id': subjectId,
    'subject_id': subjectId,
    'exam_id': examId,
    'title': subjectName,
    'title_gujarati': subjectName,
    'subject_order': subjectOrder,
    'order': subjectOrder,
    'official_marks': officialMarks,
    'total_marks_weightage': officialMarks,
    'practice_questions': practiceQuestionCount,
    'icon_name': getIconName(),
  };

  String getIconName() {
    final lower = subjectName.toLowerCase();
    if (lower.contains('reasoning')) return 'psychology';
    if (lower.contains('quantitative') || lower.contains('aptitude')) return 'calculate';
    if (lower.contains('gujarati')) return 'spellcheck';
    if (lower.contains('constitution')) return 'gavel';
    if (lower.contains('history') || lower.contains('cultural')) return 'account_balance';
    if (lower.contains('current')) return 'public';
    if (lower.contains('environment') || lower.contains('science')) return 'science';
    return 'menu_book';
  }
}

class TopicMaster {
  final String topicId;
  final String examId;
  final String subjectId;
  final String topicName;
  final int topicOrder;

  const TopicMaster({
    required this.topicId,
    required this.examId,
    required this.subjectId,
    required this.topicName,
    required this.topicOrder,
  });

  Map<String, dynamic> toMap() => {
    'id': topicId,
    'topic_id': topicId,
    'subject_id': subjectId,
    'syllabus_id': subjectId,
    'exam_id': examId,
    'title': topicName,
    'title_gujarati': topicName,
    'topic_order': topicOrder,
    'order': topicOrder,
  };
}

class OfficialSyllabusMaster {
  static const String version = '2026.1';

  // =========================================================================
  // 1. GUJARAT POLICE PSI (PAPER 1 - OBJECTIVE MCQ EXAMINATION)
  // =========================================================================
  static const ExamMaster psiExam = ExamMaster(
    examId: 'gujarat_psi',
    examCode: 'gujarat_psi',
    examName: 'Gujarat Police PSI (Paper 1)',
    description: 'પોલીસ સબ ઇન્સ્પેક્ટર પ્રિલિમિનરી પરીક્ષા પેપર-1 (સંપૂર્ણ 200 પ્રશ્નોનું પ્રશ્નપત્ર)',
    totalQuestions: 200,
    totalMarks: 200,
    durationMinutes: 180,
    negativeMarking: 0.25,
    subjects: [
      // Subject 1: Reasoning and Data Interpretation (Official: 5 marks, Practice: 9 MCQs)
      SubjectMaster(
        subjectId: 'psi_reasoning',
        examId: 'gujarat_psi',
        subjectName: 'Reasoning and Data Interpretation',
        subjectOrder: 1,
        officialMarks: 5,
        practiceQuestionCount: 9,
        topics: [
          TopicMaster(
            topicId: 'psi_reas_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_reasoning',
            topicName: 'તાર્કિક કસોટીઓ અને ડેટા અર્થઘટન (Reasoning & Data Interpretation)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 2: Quantitative Aptitude (Official: 5 marks, Practice: 9 MCQs)
      SubjectMaster(
        subjectId: 'psi_quant',
        examId: 'gujarat_psi',
        subjectName: 'Quantitative Aptitude',
        subjectOrder: 2,
        officialMarks: 5,
        practiceQuestionCount: 9,
        topics: [
          TopicMaster(
            topicId: 'psi_quant_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_quant',
            topicName: 'સંખ્યાત્મક ક્ષમતા અને મૂળભૂત ગણિત (Quantitative Aptitude)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 3: Constitution of India and Public Administration (Official: 25 marks, Practice: 46 MCQs)
      SubjectMaster(
        subjectId: 'psi_constitution',
        examId: 'gujarat_psi',
        subjectName: 'Constitution of India and Public Administration',
        subjectOrder: 3,
        officialMarks: 25,
        practiceQuestionCount: 46,
        topics: [
          TopicMaster(
            topicId: 'psi_const_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'ભારતીય બંધારણ — ઉદ્ભવ અને વિકાસ, લાક્ષણિકતાઓ, આમુખ, મૂળભૂત અધિકારો અને ફરજો, માર્ગદર્શક સિદ્ધાંતો, બંધારણીય જોગવાઈઓ, બંધારણીય સુધારા પ્રક્રિયા અને સુધારાઓ, મૂળભૂત માળખું',
            topicOrder: 1,
          ),
          TopicMaster(
            topicId: 'psi_const_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'કેન્દ્ર અને રાજ્ય સરકારો — કાર્યો અને જવાબદારીઓ',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'psi_const_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'સંસદીય વ્યવસ્થા — સંસદ અને રાજ્ય વિધાનમંડળ, માળખું, કાર્યો, સત્તાઓ અને વિશેષાધિકારો, રાષ્ટ્રપતિ અને રાજ્યપાલ, કારોબારી અને ન્યાયતંત્ર',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'psi_const_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'સમવાયી વ્યવસ્થા અને કેન્દ્ર-રાજ્ય સંબંધો',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'psi_const_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'બંધારણીય સંસ્થાઓ — વૈધાનિક, નિયમનકારી અને અર્ધ-ન્યાયિક સંસ્થાઓ',
            topicOrder: 5,
          ),
          TopicMaster(
            topicId: 'psi_const_t6',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'પંચાયતી રાજ અને સ્થાનિક સ્વરાજ્યની સંસ્થાઓ',
            topicOrder: 6,
          ),
          TopicMaster(
            topicId: 'psi_const_t7',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'ભારતીય વહીવટનો વિકાસ — પ્રાચીન ભારતથી આધુનિક ભારત સુધી',
            topicOrder: 7,
          ),
          TopicMaster(
            topicId: 'psi_const_t8',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'ન્યાયિક વ્યવસ્થા અને જાહેર સેવાઓ (Civil Services)',
            topicOrder: 8,
          ),
          TopicMaster(
            topicId: 'psi_const_t9',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'કાયદાઓ અને પ્રણાલીઓનો વહીવટ',
            topicOrder: 9,
          ),
          TopicMaster(
            topicId: 'psi_const_t10',
            examId: 'gujarat_psi',
            subjectId: 'psi_constitution',
            topicName: 'કેન્દ્ર અને રાજ્ય સરકારની મહત્વની નીતિઓ અને કાર્યક્રમો',
            topicOrder: 10,
          ),
        ],
      ),

      // Subject 4: History, Geography and Cultural Heritage (Official: 25 marks, Practice: 45 MCQs)
      SubjectMaster(
        subjectId: 'psi_history_geo_culture',
        examId: 'gujarat_psi',
        subjectName: 'History, Geography and Cultural Heritage',
        subjectOrder: 4,
        officialMarks: 25,
        practiceQuestionCount: 45,
        topics: [
          // History (12 topics)
          TopicMaster(
            topicId: 'psi_hist_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'સિંધુ ખીણની સભ્યતા (Indus Valley Civilization)',
            topicOrder: 1,
          ),
          TopicMaster(
            topicId: 'psi_hist_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'વૈદિક કાળ (Vedic Age)',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'psi_hist_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'જૈન ધર્મ અને બૌદ્ધ ધર્મ',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'psi_hist_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ગણ રાજ્યો અને પ્રથમ મગધ સામ્રાજ્ય',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'psi_hist_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'મધ્ય એશિયા સાથેના સંબંધો અને તેના પરિણામો',
            topicOrder: 5,
          ),
          TopicMaster(
            topicId: 'psi_hist_t6',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'મહત્વના ભારતીય રાજવંશો — હર્ષ, નંદ, મૌર્ય, શૃંગ, કુષાણ, સાતવાહન, ગુપ્ત, હર્ષવર્ધન, પલ્લવ, ચાલુક્ય, ગુર્જર-પ્રતિહાર, ચોલ, પાલ, દિલ્હી સલ્તનત, મુઘલ, વિજયનગર, મરાઠા અને અન્ય',
            topicOrder: 6,
          ),
          TopicMaster(
            topicId: 'psi_hist_t7',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'યુરોપિયન પ્રજાનું ભારતમાં આગમન અને સર્વોચ્ચતા માટે સ્પર્ધા',
            topicOrder: 7,
          ),
          TopicMaster(
            topicId: 'psi_hist_t8',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ભારતમાં કંપની શાસન',
            topicOrder: 8,
          ),
          TopicMaster(
            topicId: 'psi_hist_t9',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: '1857નો સંગ્રામ અને સીધું બ્રિટિશ શાસન',
            topicOrder: 9,
          ),
          TopicMaster(
            topicId: 'psi_hist_t10',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ભારતીય સ્વાતંત્ર્ય સંગ્રામ, આઝાદી અને સ્વતંત્રતા પછીનું ભારત',
            topicOrder: 10,
          ),
          TopicMaster(
            topicId: 'psi_hist_t11',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: '19મી અને 20મી સદીમાં ધાર્મિક અને સામાજિક સુધારણા આંદોલનો',
            topicOrder: 11,
          ),
          TopicMaster(
            topicId: 'psi_hist_t12',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ગુજરાતના રજવાડાઓ, શાસકો, વહીવટ, આર્થિક અને સામાજિક સ્થિતિ, ધર્મ, સાહિત્ય, કલા અને સંસ્કૃતિ',
            topicOrder: 12,
          ),

          // Geography (5 topics)
          TopicMaster(
            topicId: 'psi_geo_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'સામાન્ય ભૂગોળ — સૌરમંડળ, પૃથ્વી, પૃથ્વીની ગતિવિધિઓ, સમય અને ઋતુઓ, પૃથ્વીનું આંતરિક બંધારણ, મુખ્ય ભૂમિ સ્વરૂપો, આબોહવા, વાતાવરણ, પવનો, મહાસાગરો',
            topicOrder: 13,
          ),
          TopicMaster(
            topicId: 'psi_geo_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ભૌતિક ભૂગોળ — ભારત, ગુજરાત અને વિશ્વના કુદરતી પ્રદેશો, ભૂકંપ, ભૂસ્ખલન, ચક્રવાત, પૂર, કુદરતી આપત્તિઓ, વનસ્પતિ, રાષ્ટ્રીય ઉદ્યાનો, અભયારણ્યો, જમીનના પ્રકારો અને ખનીજો',
            topicOrder: 14,
          ),
          TopicMaster(
            topicId: 'psi_geo_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'સામાજિક ભૂગોળ — વસ્તી વિતરણ, ગીચતા, વૃદ્ધિ, જાતિ પ્રમાણ, સાક્ષરતા, આદિજાતિઓ, ભાષાકીય અને સામાજિક જૂથો',
            topicOrder: 15,
          ),
          TopicMaster(
            topicId: 'psi_geo_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'આર્થિક ભૂગોળ — કૃષિ, ઉદ્યોગો, સેવાઓ, ખનીજો, ઊર્જા, પરિવહન અને વેપાર',
            topicOrder: 16,
          ),
          TopicMaster(
            topicId: 'psi_geo_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'વર્તમાન પ્રવાહોના સંદર્ભમાં વિશ્વ ભૂગોળ',
            topicOrder: 17,
          ),

          // Cultural Heritage (7 topics)
          TopicMaster(
            topicId: 'psi_cult_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ભારત અને ગુજરાતનો સાંસ્કૃતિક વારસો — કલા સ્વરૂપો, સાહિત્ય, શિલ્પ, સ્થાપત્ય, સંગીત અને નૃત્ય',
            topicOrder: 18,
          ),
          TopicMaster(
            topicId: 'psi_cult_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ભારતીય જીવનશૈલી અને પરંપરાઓ — મેળાઓ, ઉત્સવો, ખાનપાન, પોશાક અને રીત-રિવાજો',
            topicOrder: 19,
          ),
          TopicMaster(
            topicId: 'psi_cult_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'સંગ્રહાલયો, ગ્રંથાલયો અને સાંસ્કૃતિક, ધાર્મિક તથા સાહિત્યિક મહત્વ',
            topicOrder: 20,
          ),
          TopicMaster(
            topicId: 'psi_cult_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ગુજરાતી સાંસ્કૃતિક વારસો — નાટ્યકળા, લોકગીતો અને પ્રદર્શન કળાઓ',
            topicOrder: 21,
          ),
          TopicMaster(
            topicId: 'psi_cult_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'આદિવાસી જીવનશૈલી — ઉત્સવો, મેળાઓ, પોશાક અને ધાર્મિક પરંપરાઓ',
            topicOrder: 22,
          ),
          TopicMaster(
            topicId: 'psi_cult_t6',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ગુજરાતી સાહિત્ય — આંદોલનો, સર્જકો, કૃતિઓ અને સાહિત્યિક સંસ્થાઓ',
            topicOrder: 23,
          ),
          TopicMaster(
            topicId: 'psi_cult_t7',
            examId: 'gujarat_psi',
            subjectId: 'psi_history_geo_culture',
            topicName: 'ગુજરાતના યાત્રાધામો અને પ્રવાસન સ્થળો',
            topicOrder: 24,
          ),
        ],
      ),

      // Subject 5: Current Affairs and General Knowledge (Official: 25 marks, Practice: 45 MCQs)
      SubjectMaster(
        subjectId: 'psi_current_affairs_gk',
        examId: 'gujarat_psi',
        subjectName: 'Current Affairs and General Knowledge',
        subjectOrder: 5,
        officialMarks: 25,
        practiceQuestionCount: 45,
        topics: [
          TopicMaster(
            topicId: 'psi_ca_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_current_affairs_gk',
            topicName: 'દૈનિક વર્તમાન પ્રવાહો અને સામાન્ય જ્ઞાન (Daily Current Events & General Knowledge)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 6: Environment, Science and Technology and Economics (Official: 25 marks, Practice: 46 MCQs)
      SubjectMaster(
        subjectId: 'psi_env_sci_tech_econ',
        examId: 'gujarat_psi',
        subjectName: 'Environment, Science and Technology and Economics',
        subjectOrder: 6,
        officialMarks: 25,
        practiceQuestionCount: 46,
        topics: [
          // Environment (5 topics)
          TopicMaster(
            topicId: 'psi_env_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'પર્યાવરણીય મુદ્દાઓ અને કાયદાકીય પાસાં, રાષ્ટ્રીય અને આંતરરાષ્ટ્રીય પર્યાવરણ સંરક્ષણ નીતિઓ, કરારો, જૈવવિવિધતા, ક્લાઈમેટ ચેન્જ અને ભારતના સંકલ્પો',
            topicOrder: 1,
          ),
          TopicMaster(
            topicId: 'psi_env_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'જંગલો અને વન્યજીવો — કાયદાકીય અને સંસ્થાકીય માળખું, વન્યજીવ સંરક્ષણ યોજનાઓ',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'psi_env_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'પ્રદૂષણ — પ્રકારો, ગ્લોબલ વોર્મિંગ, ગ્રીનહાઉસ અસર, ઓઝોન સ્તરનું ક્ષય, એસિડ વર્ષા, નિયંત્રણ પગલાં (હવા, પાણી અને ધ્વનિ પ્રદૂષણ)',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'psi_env_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'પર્યાવરણીય જોખમો, કાર્બન ઉત્સર્જન, ગ્લોબલ વોર્મિંગ અને નેશનલ એક્શન પ્લાન',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'psi_env_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'રાષ્ટ્રીય ઉદ્યાનો અને વન્યજીવ અભયારણ્યો',
            topicOrder: 5,
          ),

          // Science and Technology (5 topics)
          TopicMaster(
            topicId: 'psi_st_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'રોજિંદા જીવનમાં વિજ્ઞાન અને ટેકનોલોજી',
            topicOrder: 6,
          ),
          TopicMaster(
            topicId: 'psi_st_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'માહિતી અને સંચાર ટેકનોલોજી (ICT) — ઉદ્યોગ, વહીવટ, સરકારી યોજનાઓ, ઈ-ગવર્નન્સ, સાયબર સિક્યોરિટી અને નેશનલ સાયબર ક્રાઈમ પોર્ટલ',
            topicOrder: 7,
          ),
          TopicMaster(
            topicId: 'psi_st_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ભારતીય અવકાશ કાર્યક્રમ — ISRO અને અન્ય સંસ્થાઓ, પ્રવૃત્તિઓ અને સિદ્ધિઓ, ઉપગ્રહો, IRNSS અને IRS રિમોટ સેન્સિંગ',
            topicOrder: 8,
          ),
          TopicMaster(
            topicId: 'psi_st_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ભારતની વર્તમાન ઊર્જા જરૂરિયાતો, ઊર્જા સ્ત્રોતો અને ઊર્જા નીતિ',
            topicOrder: 9,
          ),
          TopicMaster(
            topicId: 'psi_st_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ભારતની અણુ નીતિ, વૈશ્વિક પ્રતિબદ્ધતાઓ અને સહયોગ',
            topicOrder: 10,
          ),

          // Economics (5 topics)
          TopicMaster(
            topicId: 'psi_econ_t1',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'આઝાદી પૂર્વેનું ભારતીય અર્થતંત્ર, આયોજન, આયોજન મોડલ, સુધારાઓ, નીતિ આયોગ — ઉદ્દેશ્યો, બંધારણ અને કાર્યો',
            topicOrder: 11,
          ),
          TopicMaster(
            topicId: 'psi_econ_t2',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ભારતીય જાહેર નાણાં — કરવેરા, જાહેર ખર્ચ, જાહેર દેવું, GST અને કેન્દ્ર-રાજ્ય નાણાકીય સંબંધો',
            topicOrder: 12,
          ),
          TopicMaster(
            topicId: 'psi_econ_t3',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ભારતનો વિદેશ વેપાર — વલણો, માળખું અને દિશા',
            topicOrder: 13,
          ),
          TopicMaster(
            topicId: 'psi_econ_t4',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'કૃષિ ક્ષેત્ર — પાક, સિંચાઈ, જમીન સુધારણા, ટેકનોલોજી, ઉત્પાદકતા, એગ્રીકલ્ચર માર્કેટિંગ, ખાદ્ય સુરક્ષા, હરિયાળી ક્રાંતિ, ઓર્ગેનિક ખેતી',
            topicOrder: 14,
          ),
          TopicMaster(
            topicId: 'psi_econ_t5',
            examId: 'gujarat_psi',
            subjectId: 'psi_env_sci_tech_econ',
            topicName: 'ગુજરાતનું અર્થતંત્ર — શિક્ષણ, આરોગ્ય, પોષણ, કૃષિ, જંગલો, જળ સંસાધન, ખનન, ઉદ્યોગો, સેવાઓ, ઇન્ફ્રાસ્ટ્રક્ચર અને સહકારી ક્ષેત્ર',
            topicOrder: 15,
          ),
        ],
      ),
    ],
  );

  // =========================================================================
  // 2. GUJARAT POLICE LRD / CONSTABLE (PAPER 1 - OBJECTIVE MCQ EXAMINATION)
  // =========================================================================
  static const ExamMaster lrdExam = ExamMaster(
    examId: 'gujarat_lrd',
    examCode: 'gujarat_lrd',
    examName: 'Gujarat Police LRD / Constable',
    description: 'લોકરક્ષક દળ / કોન્સ્ટેબલ પરીક્ષા પેપર-1 (સંપૂર્ણ 200 પ્રશ્નોનું પ્રશ્નપત્ર)',
    totalQuestions: 200,
    totalMarks: 200,
    durationMinutes: 180,
    negativeMarking: 0.25,
    subjects: [
      // Subject 1: Reasoning and Data Interpretation (Official: 30 marks, Practice: 30 MCQs)
      SubjectMaster(
        subjectId: 'lrd_reasoning',
        examId: 'gujarat_lrd',
        subjectName: 'Reasoning and Data Interpretation',
        subjectOrder: 1,
        officialMarks: 30,
        practiceQuestionCount: 30,
        topics: [
          TopicMaster(
            topicId: 'lrd_reas_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_reasoning',
            topicName: 'તાર્કિક કસોટીઓ અને ડેટા અર્થઘટન (Reasoning & Data Interpretation)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 2: Quantitative Aptitude (Official: 30 marks, Practice: 30 MCQs)
      SubjectMaster(
        subjectId: 'lrd_quant',
        examId: 'gujarat_lrd',
        subjectName: 'Quantitative Aptitude',
        subjectOrder: 2,
        officialMarks: 30,
        practiceQuestionCount: 30,
        topics: [
          TopicMaster(
            topicId: 'lrd_quant_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_quant',
            topicName: 'સંખ્યાત્મક ક્ષમતા અને મૂળભૂત ગણિત (Quantitative Aptitude)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 3: Comprehension in Gujarati Language (Official: 20 marks, Practice: 20 MCQs)
      // IMPORTANT: Passages based comprehension, NOT renamed to Grammar!
      SubjectMaster(
        subjectId: 'lrd_gujarati_comprehension',
        examId: 'gujarat_lrd',
        subjectName: 'Comprehension in Gujarati Language',
        subjectOrder: 3,
        officialMarks: 20,
        practiceQuestionCount: 20,
        topics: [
          TopicMaster(
            topicId: 'lrd_comp_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_gujarati_comprehension',
            topicName: 'ગુજરાતી ભાષામાં ગદ્યાર્થગ્રહણ (Comprehension based on Passages)',
            topicOrder: 1,
          ),
        ],
      ),

      // Subject 4: The Constitution of India (Official: 30 marks, Practice: 30 MCQs)
      SubjectMaster(
        subjectId: 'lrd_constitution',
        examId: 'gujarat_lrd',
        subjectName: 'The Constitution of India',
        subjectOrder: 4,
        officialMarks: 30,
        practiceQuestionCount: 30,
        topics: [
          TopicMaster(
            topicId: 'lrd_const_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_constitution',
            topicName: 'ભારતીય બંધારણ — ઉદ્ભવ અને વિકાસ, લાક્ષણિકતાઓ, આમુખ, મૂળભૂત અધિકારો અને ફરજો, માર્ગદર્શક સિદ્ધાંતો, બંધારણીય જોગવાઈઓ, સુધારાઓ અને મૂળભૂત માળખું',
            topicOrder: 1,
          ),
          TopicMaster(
            topicId: 'lrd_const_t2',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_constitution',
            topicName: 'કેન્દ્ર અને રાજ્ય સરકારો — કાર્યો અને જવાબદારીઓ; સંસદીય વ્યવસ્થા; સંસદ અને રાજ્ય વિધાનમંડળ — માળખું, કાર્યો, સત્તાઓ અને વિશેષાધિકારો; રાષ્ટ્રપતિ અને રાજ્યપાલ; કારોબારી અને ન્યાયતંત્ર',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'lrd_const_t3',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_constitution',
            topicName: 'સમવાયી વ્યવસ્થા અને કેન્દ્ર-રાજ્ય સંબંધો',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'lrd_const_t4',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_constitution',
            topicName: 'બંધારણીય સંસ્થાઓ — વૈધાનિક, નિયમનકારી અને અર્ધ-ન્યાયિક સંસ્થાઓ',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'lrd_const_t5',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_constitution',
            topicName: 'પંચાયતી રાજ અને સ્થાનિક સ્વરાજ્યની સંસ્થાઓ',
            topicOrder: 5,
          ),
        ],
      ),

      // Subject 5: Current Affairs, Science and Technology, General Knowledge (Official: 40 marks, Practice: 40 MCQs)
      SubjectMaster(
        subjectId: 'lrd_current_affairs_st_gk',
        examId: 'gujarat_lrd',
        subjectName: 'Current Affairs, Science and Technology, General Knowledge',
        subjectOrder: 5,
        officialMarks: 40,
        practiceQuestionCount: 40,
        topics: [
          // Current Affairs (1 topic)
          TopicMaster(
            topicId: 'lrd_ca_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'દૈનિક વર્તમાન ઘટનાઓ અને સામાન્ય જ્ઞાન (Daily Current Events)',
            topicOrder: 1,
          ),
          // Science and Technology (15 topics)
          TopicMaster(
            topicId: 'lrd_st_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'ખોરાકના ઘટકો અને પોષણ, ખાદ્ય ઉત્પાદન અને વ્યવસ્થાપન, ખાદ્ય સંસાધનોમાં સુધારો',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'lrd_st_t2',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'સજીવોના લક્ષણો, વિવિધતા, પોષણ, અનુકૂલન, સજીવોના અંગો અને તંત્રો, સંરક્ષણ',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'lrd_st_t3',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'આપણી આસપાસ થતા ભૌતિક અને રાસાયણિક ફેરફારો',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'lrd_st_t4',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'ગતિ, ઝડપ, બળ, દબાણ, ગુરુત્વાકર્ષણ, કાર્ય અને ઊર્જા',
            topicOrder: 5,
          ),
          TopicMaster(
            topicId: 'lrd_st_t5',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'વિદ્યુત અને પરિપથ, વિદ્યુતપ્રવાહ અને તેની અસરો',
            topicOrder: 6,
          ),
          TopicMaster(
            topicId: 'lrd_st_t6',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'કુદરતી અને કૃત્રિમ રેસાઓ, કપાસ અને પ્લાસ્ટિક',
            topicOrder: 7,
          ),
          TopicMaster(
            topicId: 'lrd_st_t7',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'એસિડ, બેઇઝ અને ક્ષાર',
            topicOrder: 8,
          ),
          TopicMaster(
            topicId: 'lrd_st_t8',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'ચુંબક, ઉષ્મા, ધ્વનિ, દહન, ધાતુઓ, અધાતુઓ, કોલસો અને પેટ્રોલિયમ',
            topicOrder: 9,
          ),
          TopicMaster(
            topicId: 'lrd_st_t9',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'સૂક્ષ્મજીવો, સ્વસ્થ શરીર, રોગો અને તેના કારણો',
            topicOrder: 10,
          ),
          TopicMaster(
            topicId: 'lrd_st_t10',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'હવા અને તેનું બંધારણ, પવન, વાવાઝોડું, ચક્રવાત, હવામાન અને આબોહવા, વાયુ પ્રદૂષણ',
            topicOrder: 11,
          ),
          TopicMaster(
            topicId: 'lrd_st_t11',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'પાણી અને તેના સ્ત્રોતો, જળચક્ર, બાષ્પીભવન, વરસાદ, જળ સંગ્રહ અને સંરક્ષણ, જળ પ્રદૂષણ',
            topicOrder: 12,
          ),
          TopicMaster(
            topicId: 'lrd_st_t12',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'કચરો સંગ્રહ અને નિકાલ',
            topicOrder: 13,
          ),
          TopicMaster(
            topicId: 'lrd_st_t13',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'જમીન, જંગલો અને તેનું મહત્વ, કુદરતી સંસાધનો, ઊર્જા સ્ત્રોતો, જૈવ-ભૂ-રાસાયણિક ચક્રો',
            topicOrder: 14,
          ),
          TopicMaster(
            topicId: 'lrd_st_t14',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'તારાઓ અને સૂર્યમંડળ',
            topicOrder: 15,
          ),
          TopicMaster(
            topicId: 'lrd_st_t15',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_current_affairs_st_gk',
            topicName: 'પર્યાવરણ, સંરક્ષણ, પ્રદૂષણ અને પ્રદૂષણ નિયંત્રણ',
            topicOrder: 16,
          ),
        ],
      ),

      // Subject 6: History, Cultural Heritage and Geography of Gujarat and Bharat (Official: 50 marks, Practice: 50 MCQs)
      SubjectMaster(
        subjectId: 'lrd_history_culture_geo',
        examId: 'gujarat_lrd',
        subjectName: 'History, Cultural Heritage and Geography of Gujarat and Bharat',
        subjectOrder: 6,
        officialMarks: 50,
        practiceQuestionCount: 50,
        topics: [
          // History (12 topics)
          TopicMaster(
            topicId: 'lrd_hist_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'સિંધુ ખીણની સભ્યતા (Indus Valley Civilization)',
            topicOrder: 1,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t2',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'વૈદિક કાળ (Vedic Age)',
            topicOrder: 2,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t3',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'જૈન ધર્મ અને બૌદ્ધ ધર્મ',
            topicOrder: 3,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t4',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ગણ રાજ્યો અને પ્રથમ મગધ સામ્રાજ્ય',
            topicOrder: 4,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t5',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'મધ્ય એશિયા સાથેના સંબંધો અને તેના પરિણામો',
            topicOrder: 5,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t6',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'મહત્વના ભારતીય રાજવંશો — હર્ષ, નંદ, મૌર્ય, શૃંગ, કુષાણ, સાતવાહન, ગુપ્ત, હર્ષવર્ધન, પલ્લવ, ચાલુક્ય, ગુર્જર-પ્રતિહાર, ચોલ, પાલ, દિલ્હી સલ્તનત, મુઘલ, વિજયનગર, મરાઠા અને અન્ય',
            topicOrder: 6,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t7',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'યુરોપિયન પ્રજાનું ભારતમાં આગમન અને સર્વોચ્ચતા માટે સ્પર્ધા',
            topicOrder: 7,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t8',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ભારતમાં કંપની શાસન',
            topicOrder: 8,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t9',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: '1857નો સંગ્રામ અને સીધું બ્રિટિશ શાસન',
            topicOrder: 9,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t10',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ભારતીય સ્વાતંત્ર્ય સંગ્રામ, આઝાદી અને સ્વતંત્રતા પછીનું ભારત',
            topicOrder: 10,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t11',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: '19મી અને 20મી સદીમાં ધાર્મિક અને સામાજિક સુધારણા આંદોલનો',
            topicOrder: 11,
          ),
          TopicMaster(
            topicId: 'lrd_hist_t12',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ગુજરાતના રજવાડાઓ, શાસકો, વહીવટ, આર્થિક અને સામાજિક સ્થિતિ, ધર્મ, સાહિત્ય, કલા અને સંસ્કૃતિ',
            topicOrder: 12,
          ),

          // Cultural Heritage (7 topics)
          TopicMaster(
            topicId: 'lrd_cult_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ભારત અને ગુજરાતનો સાંસ્કૃતિક વારસો — કલા સ્વરૂપો, સાહિત્ય, શિલ્પ, સ્થાપત્ય, સંગીત અને નૃત્ય',
            topicOrder: 13,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t2',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ભારતીય જીવનશૈલી અને પરંપરાઓ — મેળાઓ, ઉત્સવો, ખાનપાન, પોશાક અને રીત-રિવાજો',
            topicOrder: 14,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t3',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'સંગ્રહાલયો, ગ્રંથાલયો અને સાંસ્કૃતિક, ધાર્મિક તથા સાહિત્યિક મહત્વ',
            topicOrder: 15,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t4',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ગુજરાતી સાંસ્કૃતિક વારસો — નાટ્યકળા, લોકગીતો અને પ્રદર્શન કળાઓ',
            topicOrder: 16,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t5',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'આદિવાસી જીવનશૈલી — ઉત્સવો, મેળાઓ, પોશાક અને ધાર્મિક પરંપરાઓ',
            topicOrder: 17,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t6',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ગુજરાતી સાહિત્ય — આંદોલનો, સર્જકો, કૃતિઓ અને સાહિત્યિક સંસ્થાઓ',
            topicOrder: 18,
          ),
          TopicMaster(
            topicId: 'lrd_cult_t7',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ગુજરાતના યાત્રાધામો અને પ્રવાસન સ્થળો',
            topicOrder: 19,
          ),

          // Geography (5 topics)
          TopicMaster(
            topicId: 'lrd_geo_t1',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'સામાન્ય ભૂગોળ — સૌરમંડળ, પૃથ્વી, પૃથ્વીની ગતિવિધિઓ, સમય અને ઋતુઓ, પૃથ્વીનું આંતરિક બંધારણ, મુખ્ય ભૂમિ સ્વરૂપો, આબોહવા, વાતાવરણ, પવનો, મહાસાગરો, ભૌતિક, રાસાયણિક અને જૈવિક લક્ષણો, જળ સંસાધન, સમુદ્રી અને ટાપુ સંસાધનો',
            topicOrder: 20,
          ),
          TopicMaster(
            topicId: 'lrd_geo_t2',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'ભૌતિક ભૂગોળ — મુખ્ય કુદરતી પ્રદેશો, ભૂકંપ, ભૂસ્ખલન, ચક્રવાત, પૂર અને કુદરતી આપત્તિઓ, કુદરતી વનસ્પતિ, રાષ્ટ્રીય ઉદ્યાનો, વન્યજીવ અભયારણ્યો, જમીનના પ્રકારો, ખડકો અને ખનીજો',
            topicOrder: 21,
          ),
          TopicMaster(
            topicId: 'lrd_geo_t3',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'સામાજિક ભૂગોળ — વસ્તી વિતરણ, વસ્તી, ગીચતા, વૃદ્ધિ, જાતિ પ્રમાણ, સાક્ષરતા, આદિજાતિઓ, બિન-આદિજાતિ જૂથો અને ભાષાકીય જૂથો',
            topicOrder: 22,
          ),
          TopicMaster(
            topicId: 'lrd_geo_t4',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'આર્થિક ભૂગોળ — કૃષિ, ઉદ્યોગો, સેવાઓ, કૃષિ આધારિત ઉદ્યોગો, ખનીજો, જંગલો, સિંચાઈ અને બંધો, શ્રમ આધારિત ઉદ્યોગો, પરિવહન અને વેપાર',
            topicOrder: 23,
          ),
          TopicMaster(
            topicId: 'lrd_geo_t5',
            examId: 'gujarat_lrd',
            subjectId: 'lrd_history_culture_geo',
            topicName: 'વર્તમાન પ્રવાહોના સંદર્ભમાં વિશ્વની ભૂગોળ',
            topicOrder: 24,
          ),
        ],
      ),
    ],
  );

  static List<ExamMaster> get allExams => [psiExam, lrdExam];

  static ExamMaster? getExamById(String id) {
    final lower = id.toLowerCase().trim();
    if (lower == 'gujarat_psi' || lower == 'psi' || lower.contains('psi')) return psiExam;
    if (lower == 'gujarat_lrd' || lower == 'constable' || lower == 'lrd' || lower.contains('lrd') || lower.contains('constable')) return lrdExam;
    return null;
  }

  /// Get subjects for exam
  static List<SubjectMaster> getSubjectsForExam(String examId) {
    final exam = getExamById(examId);
    return exam?.subjects ?? [];
  }

  /// Find official subject by name or keyword
  static SubjectMaster? findSubject(String examId, String inputName) {
    final exam = getExamById(examId);
    if (exam == null) return null;

    final trimmed = inputName.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    // Exact or direct substring match
    for (final s in exam.subjects) {
      if (s.subjectId.toLowerCase() == trimmed) return s;
      if (s.subjectName.toLowerCase() == trimmed) return s;
      if (trimmed.contains(s.subjectName.toLowerCase()) || s.subjectName.toLowerCase().contains(trimmed)) {
        return s;
      }
    }

    // Keyword heuristics
    if (trimmed.contains('reasoning') || trimmed.contains('તાર્કિક') || trimmed.contains('રીઝનીંગ') || trimmed.contains('રિઝનિંગ')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('reasoning'));
    }
    if (trimmed.contains('quant') || trimmed.contains('ગણિત') || trimmed.contains('math') || trimmed.contains('સંખ્યાત્મક')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('quant'));
    }
    if (trimmed.contains('gujarati') || trimmed.contains('ગુજરાતી') || trimmed.contains('વ્યાકરણ') || trimmed.contains('grammar')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('gujarati'), orElse: () => exam.subjects.first);
    }
    if (trimmed.contains('constitution') || trimmed.contains('બંધારણ') || trimmed.contains('polity') || trimmed.contains('રાજ્યવ્યવસ્થા')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('constitution'));
    }
    if (trimmed.contains('history') || trimmed.contains('ઇતિહાસ') || trimmed.contains('ઈતિહાસ') || trimmed.contains('culture') || trimmed.contains('વારસો') || trimmed.contains('સાંસ્કૃતિક')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('history') || s.subjectId.contains('culture'));
    }
    if (trimmed.contains('current') || trimmed.contains('વર્તમાન') || trimmed.contains('gk') || trimmed.contains('સામાન્ય જ્ઞાન') || trimmed.contains('પ્રવાહો')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('current'));
    }
    if (trimmed.contains('environment') || trimmed.contains('પર્યાવરણ') || trimmed.contains('science') || trimmed.contains('વિજ્ઞાન') || trimmed.contains('economics') || trimmed.contains('અર્થતંત્ર')) {
      return exam.subjects.firstWhere((s) => s.subjectId.contains('env') || s.subjectId.contains('science'));
    }

    return null;
  }

  /// Find topic inside a subject
  static TopicMaster? findTopic(SubjectMaster subject, String inputName) {
    final trimmed = inputName.trim().toLowerCase();
    if (trimmed.isEmpty) return subject.topics.isNotEmpty ? subject.topics.first : null;

    for (final t in subject.topics) {
      if (t.topicId.toLowerCase() == trimmed) return t;
      if (t.topicName.toLowerCase() == trimmed) return t;
      if (t.topicName.toLowerCase().contains(trimmed) || trimmed.contains(t.topicName.toLowerCase())) {
        return t;
      }
    }

    return subject.topics.isNotEmpty ? subject.topics.first : null;
  }

  /// Idempotently seed Official Syllabus structure into Firestore collections:
  /// - `exams`
  /// - `subjects`
  /// - `topics`
  /// - `syllabus` (legacy sync)
  /// - `syllabus_topics` (legacy sync)
  static Future<Map<String, int>> seedToFirestore(
    Future<bool> Function(String collection, String docId, Map<String, dynamic> data) setDocFn, {
    void Function(String msg)? onProgress,
  }) async {
    int examsCount = 0;
    int subjectsCount = 0;
    int topicsCount = 0;

    for (final exam in allExams) {
      onProgress?.call('Seeding Exam: ${exam.examName}');
      await setDocFn('exams', exam.examId, exam.toMap());
      examsCount++;

      for (final subject in exam.subjects) {
        onProgress?.call('Seeding Subject: ${subject.subjectName}');
        final subMap = subject.toMap();
        await setDocFn('subjects', subject.subjectId, subMap);
        // Legacy compatibility sync
        await setDocFn('syllabus', subject.subjectId, subMap);
        subjectsCount++;

        for (final topic in subject.topics) {
          final topMap = topic.toMap();
          await setDocFn('topics', topic.topicId, topMap);
          // Legacy compatibility sync
          await setDocFn('syllabus_topics', topic.topicId, topMap);
          topicsCount++;
        }
      }
    }

    return {
      'exams': examsCount,
      'subjects': subjectsCount,
      'topics': topicsCount,
    };
  }
}
