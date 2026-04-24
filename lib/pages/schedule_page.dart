import 'package:flutter/material.dart';

import '../models/course.dart';

// Sample data matching the screenshot layout
final List<Course> _sampleCourses = [
  const Course(
    name: '植物保护学通论(B)',
    location: '逸夫楼B区-逸夫楼B104',
    dayOfWeek: 1,
    startPeriod: 1,
    endPeriod: 2,
    color: CourseColor.green,
  ),
  const Course(
    name: '面向对象程序设计',
    location: '田家炳楼-204',
    dayOfWeek: 2,
    startPeriod: 1,
    endPeriod: 2,
    color: CourseColor.primary,
  ),
  const Course(
    name: '英语四六级备考',
    location: '静雅楼C区大礼堂',
    dayOfWeek: 3,
    startPeriod: 1,
    endPeriod: 2,
    color: CourseColor.orange,
  ),
  const Course(
    name: '成本与管理会计',
    location: '教学北区A楼A-501教室',
    dayOfWeek: 4,
    startPeriod: 1,
    endPeriod: 1,
    color: CourseColor.tertiary,
  ),
  const Course(
    name: '无机及分析化学',
    location: '校本部 明义楼',
    dayOfWeek: 5,
    startPeriod: 1,
    endPeriod: 1,
    color: CourseColor.secondary,
  ),
  const Course(
    name: '公共体育2',
    location: '(金)校内游泳池',
    dayOfWeek: 7,
    startPeriod: 1,
    endPeriod: 1,
    color: CourseColor.pink,
  ),
  const Course(
    name: '统计学与统计软件',
    location: '四方楼西楼-109',
    dayOfWeek: 3,
    startPeriod: 2,
    endPeriod: 3,
    color: CourseColor.primary,
  ),
  const Course(
    name: '生态旅游',
    location: '曲阜校区教学楼A419',
    dayOfWeek: 4,
    startPeriod: 2,
    endPeriod: 3,
    color: CourseColor.green,
  ),
  const Course(
    name: '时尚形象塑造与传播',
    location: '临平-L4-113',
    dayOfWeek: 6,
    startPeriod: 2,
    endPeriod: 3,
    color: CourseColor.pink,
  ),
  const Course(
    name: '建筑工程计量与计价',
    location: '',
    dayOfWeek: 2,
    startPeriod: 3,
    endPeriod: 3,
    color: CourseColor.orange,
  ),
  const Course(
    name: '英语四六级备考',
    location: '静雅楼C区大礼堂',
    dayOfWeek: 5,
    startPeriod: 3,
    endPeriod: 3,
    color: CourseColor.secondary,
  ),
  const Course(
    name: 'C语言程序设计',
    location: '2311-46 座位\n复材大楼C321',
    dayOfWeek: 1,
    startPeriod: 4,
    endPeriod: 4,
    color: CourseColor.tertiary,
  ),
  const Course(
    name: '专业导论与认知实习',
    location: '东区第二公共教学楼A407',
    dayOfWeek: 3,
    startPeriod: 4,
    endPeriod: 4,
    color: CourseColor.orange,
  ),
  const Course(
    name: '幼儿园环境创设',
    location: '',
    dayOfWeek: 4,
    startPeriod: 4,
    endPeriod: 4,
    color: CourseColor.green,
  ),
  const Course(
    name: '美学原理',
    location: '垒球馆103',
    dayOfWeek: 7,
    startPeriod: 4,
    endPeriod: 4,
    color: CourseColor.primary,
  ),
  const Course(
    name: '田间试验与统计分析',
    location: '大学城 文清306',
    dayOfWeek: 3,
    startPeriod: 5,
    endPeriod: 6,
    color: CourseColor.orange,
  ),
];

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _weekStart;
  final List<Course> _courses = _sampleCourses;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _weekStart = now.subtract(Duration(days: now.weekday - 1));
    });
  }

  int get _weekNumber {
    final dayOfYear = _weekStart.difference(DateTime(_weekStart.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第$_weekNumber周',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${_weekStart.year}-${_weekStart.year + 1} '
              '${_weekStart.month >= 9 ? '秋季' : '春季'} 学期',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: _goToToday,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous week',
            onPressed: _previousWeek,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next week',
            onPressed: _nextWeek,
          ),
        ],
      ),
      body: Column(
        children: [
          _DayHeader(
            weekStart: _weekStart,
            today: today,
          ),
          const Divider(height: 1),
          Expanded(
            child: _TimetableGrid(
              courses: _courses,
              weekStart: _weekStart,
              today: today,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime weekStart;
  final DateTime today;

  const _DayHeader({required this.weekStart, required this.today});

  static const _dayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Time column spacer
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                '${weekStart.month}\n月',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // Day columns
          for (int i = 0; i < 7; i++) ...[
            Expanded(
              child: _DayHeaderCell(
                dayLabel: _dayLabels[i],
                date: weekStart.add(Duration(days: i)),
                isToday: _isSameDay(
                  weekStart.add(Duration(days: i)),
                  today,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayHeaderCell extends StatelessWidget {
  final String dayLabel;
  final DateTime date;
  final bool isToday;

  const _DayHeaderCell({
    required this.dayLabel,
    required this.date,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isToday
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 28,
          height: 28,
          decoration: isToday
              ? BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isToday
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimetableGrid extends StatelessWidget {
  final List<Course> courses;
  final DateTime weekStart;
  final DateTime today;

  const _TimetableGrid({
    required this.courses,
    required this.weekStart,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period labels column
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  for (final period in defaultPeriods)
                    _PeriodLabel(period: period),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Day columns with course blocks
            for (int day = 1; day <= 7; day++)
              Expanded(
                child: _DayColumn(
                  dayOfWeek: day,
                  courses: courses.where((c) => c.dayOfWeek == day).toList(),
                  isToday: _isSameDay(
                    weekStart.add(Duration(days: day - 1)),
                    today,
                  ),
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _PeriodLabel extends StatelessWidget {
  final Period period;

  const _PeriodLabel({required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _kPeriodHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${period.number}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            period.startTime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          Text(
            period.endTime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

const double _kPeriodHeight = 100.0;

class _DayColumn extends StatelessWidget {
  final int dayOfWeek;
  final List<Course> courses;
  final bool isToday;
  final ThemeData theme;

  const _DayColumn({
    required this.dayOfWeek,
    required this.courses,
    required this.isToday,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid lines + today highlight
        Column(
          children: [
            for (int i = 0; i < defaultPeriods.length; i++)
              Container(
                height: _kPeriodHeight,
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primaryContainer.withAlpha(25)
                      : null,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(80),
                      width: 0.5,
                    ),
                    right: dayOfWeek < 7
                        ? BorderSide(
                            color:
                                theme.colorScheme.outlineVariant.withAlpha(80),
                            width: 0.5,
                          )
                        : BorderSide.none,
                  ),
                ),
              ),
          ],
        ),
        // Course blocks
        for (final course in courses)
          Positioned(
            top: (course.startPeriod - 1) * _kPeriodHeight + 2,
            left: 2,
            right: 2,
            height:
                (course.endPeriod - course.startPeriod + 1) * _kPeriodHeight -
                    4,
            child: _CourseBlock(course: course),
          ),
      ],
    );
  }
}

class _CourseBlock extends StatelessWidget {
  final Course course;

  const _CourseBlock({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final containerColor = course.color.containerColor(colorScheme);
    final textColor = course.color.onContainerColor(colorScheme);

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showCourseDetail(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (course.location.isNotEmpty) ...[
                const Spacer(),
                Text(
                  course.location,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontSize: 9,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseDetail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (course.location.isNotEmpty)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  text: course.location,
                  color: colorScheme.onSurfaceVariant,
                ),
              _DetailRow(
                icon: Icons.schedule_outlined,
                text: _timeRange(),
                color: colorScheme.onSurfaceVariant,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                text: _dayName(),
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeRange() {
    final start = defaultPeriods[course.startPeriod - 1];
    final end = defaultPeriods[course.endPeriod - 1];
    return '${start.startTime} – ${end.endTime}  (第${course.startPeriod}-${course.endPeriod}节)';
  }

  String _dayName() {
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[course.dayOfWeek - 1];
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
