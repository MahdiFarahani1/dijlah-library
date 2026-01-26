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
                title: "من نحن",
                content: "مكتبة دجلة هي مكتبة إلكترونية تهدف إلى نشر المعرفة "
                    "وتوفير مصادر القراءة المتنوعة لجميع الفئات. "
                    "نسعى إلى الجمع بين الأصالة والحداثة في المحتوى "
                    "مع تجربة استخدام سهلة وممتعة داخل التطبيق.",
              ),
              _buildSection(
                icon: Assets.newicons.bookOpenCover.path,
                title: "رؤيتنا",
                content: "نطمح إلى أن تكون مكتبة دجلة منصة معرفية رائدة "
                    "تسهم في تعزيز ثقافة القراءة في العالم العربي. "
                    "نؤمن بأن المعرفة حق للجميع وسلاح للتقدم. "
                    "ونسعى للوصول إلى كل قارئ أينما كان.",
              ),
              _buildSection(
                icon: Assets.newicons.taskChecklist.path,
                title: "رسالتنا",
                content: "توفير محتوى ثقافي وتعليمي موثوق بجودة عالية. "
                    "دعم القرّاء والباحثين بمصادر رقمية متنوعة. "
                    "تشجيع عادة القراءة اليومية بأسلوب عصري. "
                    "والمساهمة في بناء مجتمع واعٍ ومثقف.",
              ),
              _buildSection(
                icon: Assets.newicons.circleBookmark.path,
                title: "محتوى المكتبة",
                content: "تضم مكتبة دجلة آلاف الكتب الإلكترونية المتنوعة. "
                    "تشمل الأدب، العلوم، التاريخ، والتنمية الذاتية. "
                    "مع تحديث مستمر وإضافة إصدارات جديدة. "
                    "لتلبية اهتمامات القرّاء بمختلف أعمارهم.",
              ),
              _buildSection(
                icon: Assets.newicons.teamCheck.path,
                title: "لماذا مكتبة دجلة",
                content: "سهولة الوصول والبحث داخل التطبيق. "
                    "تصميم بسيط يراعي راحة المستخدم. "
                    "محتوى منظم وخيارات قراءة مرنة. "
                    "ودعم مستمر لتجربة قراءة مميزة.",
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
