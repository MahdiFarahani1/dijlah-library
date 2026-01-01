import 'package:bookapp/gen/assets.gen.dart';
import 'package:bookapp/shared/scaffold/appbar.dart';
import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppbar.littleAppBar(context, title: ""),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                icon: Assets.newicons.commentInfo.path,
                title: "الوصول السهل",
                content:
                    "مكتبة الشهيد الحكيم بين يديك عبر تطبيق إلكتروني حديث. "
                    "يمكنك تصفح العشرات من مؤلفات شهيد المحراب من هاتفك أو جهازك اللوحي بكل سهولة.",
              ),
              _buildSection(
                icon: Assets.newicons.bookOpenCover.path,
                title: "تنوع المحتوى",
                content:
                    "يضم التطبيق مكتبة واسعة تشمل القرآن الكريم وعلومه، الأدب، التاريخ، السياسة، العقيدة وغيرها. "
                    "كل قسم مصمم ليخدم الباحث والقارئ العام، مما يضمن تجربة معرفية غنية لكل مستخدم.",
              ),
              _buildSection(
                icon: Assets.newicons.taskChecklist.path,
                title: "خدمات رقمية",
                content:
                    "يوفر التطبيق مجموعة من الخدمات المتقدمة مثل البحث الذكي، التعليق، إكمال المطالعة، "
                    "المطابقة مع النسخ المطبوعة، وحفظ الكتب المفضلة. كما يتيح تحميل الكتب للقراءة دون اتصال بالإنترنت، "
                    "وكل ذلك عبر واجهة سهلة وسلسة.",
              ),
              _buildSection(
                icon: Assets.newicons.circleBookmark.path,
                title: "الهوية والقيم",
                content:
                    "يحمل التطبيق اسم الشهيد الحكيم رمزًا للعلم والتضحية، ويقوم على قيم نشر الوعي وخدمة المجتمع. "
                    "كما يلتزم بتعزيز الثقافة الإسلامية الأصيلة وترسيخ القيم الإنسانية.",
              ),
              _buildSection(
                icon: Assets.newicons.teamCheck.path,
                title: "تطوير مستمر",
                content:
                    "يعمل التطبيق على تحديث المحتوى بشكل دوري، ويسعى إلى إدخال تقنيات حديثة مثل القراءة الصوتية "
                    "والذكاء الاصطناعي، بهدف أن يكون منصة بحثية رائدة في العالم الرقمي.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.tertiary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  icon,
                  width: 25,
                  height: 25,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
