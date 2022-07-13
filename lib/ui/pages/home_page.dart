import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/pages/add_task_page.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/task_tile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    taskController.getTasks();
  }

  final TaskController taskController = Get.put(TaskController());
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: appBar(),
      body: Column(
        children: [
          addTaskBar(),
          addDateBar(),
         const SizedBox(
            height: 20,
          ),
          showTasks()
        ],
      ),
    );
  }

  addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                "Today",
                style: subHeadingStyle,
              ),
            ],
          ),
          MyButton(
              label: "+ Ad Task",
              onTap: () async {
                await Get.to(const AddTaskPage());
                taskController.getTasks();
              }),
        ],
      ),
    );
  }

  addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 100,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        initialSelectedDate: selectedDate,
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        onDateChange: (newDate) {
          setState(() {
            selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> onRefresh() async {
    taskController.getTasks();
  }

  showTasks() {
    return Expanded(
      child: Obx(() {
        if (taskController.taskList.isEmpty) {
          return noTaskMsg();
        } else {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var task = taskController.taskList[index];
                if (task.date == DateFormat.yMd().format(selectedDate) ||
                    task.repeat == 'Daily' ||
                    (task.repeat == "Weekly" &&
                        selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0)||(task.repeat=="Monthly"&&DateFormat.yMd().parse(task.date!).day==selectedDate.day)) {
                  var hour = task.startTime.toString().split(':')[0];
                  var minutes = task.startTime.toString().split(':')[1];
                  //OR
                  var date = DateFormat.jm().parse(task.startTime!);
                  var myTime = DateFormat('HH:mm').format(date);
                  var newHour=myTime.split(':')[0];
                  var newMinutes=myTime.split(':')[1];

                  notifyHelper.scheduledNotification(
                     int.parse(newHour),  int.parse(newMinutes), task);
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 2000),
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              context,
                              task,
                            );
                          },
                          child: TaskTile(task: task),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              itemCount: taskController.taskList.length,
            ),
          );
        }
      }),
    );
  }

  noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                    height: 6,
                  )
                      : const SizedBox(
                    height: 100,
                  ),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 100,
                    semanticsLabel: 'Task',
                    color: primaryClr.withOpacity(.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: SizedBox(
                      width: 400,
                      child: Text(
                        "you don't have any tasks yet ! Add new tasks to make your days better",
                        style: subTitleStyle,

                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                    height: 120,
                  )
                      : const SizedBox(
                    height: 180,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * .6
                : SizeConfig.screenHeight * .8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * .3
                : SizeConfig.screenHeight * .39),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Expanded(
          child: Column(
            children: [
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              task.isCompleted == 1
                  ? Container()
                  : Column(
                      children: [
                        buildBottomSheet(
                          label: 'Task Completed ',
                          onTap: () {
                            notifyHelper.cancelNotification(task);

                            taskController.markTaskAsCompleted(task.id!);
                            Get.back();
                          },
                          color: primaryClr,
                        ),
                        buildBottomSheet(
                          label: 'Delete Task ',
                          onTap: () {
                            notifyHelper.cancelNotification(task);
                            taskController.deleteTasks(task);
                            Get.back();
                          },
                          color: Colors.red[300]!,
                        ),
                        Divider(
                          color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                        ),
                        buildBottomSheet(
                          label: ' Cancel ',
                          onTap: () {
                            Get.back();
                          },
                          color: primaryClr,
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    ));
  }

  buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color color,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * .9,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[300]
                  : color)!,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isClose ? Colors.transparent : color),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Get.isDarkMode ? Brightness.light : Brightness.dark),
      leading: IconButton(
        onPressed: () {
          ThemeServices().switchTheme();
        },
        icon: Icon(
          Get.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round_outlined,
          size: 24,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).backgroundColor,
      actions:  [
        IconButton(
          onPressed: () {
            notifyHelper.cancelAllNotification();

            taskController.deleteAllTasks();

},
          icon: Icon(
           Icons.playlist_remove_outlined,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),

      const  CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage("images/person.jpeg"),
        ),
      const  SizedBox(
          width: 20,
        )
      ],
    );
  }
}
