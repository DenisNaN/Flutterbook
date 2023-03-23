import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/appointments/AppointmentsModel.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsDBWorker.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

/// ********************************************************************************************************************
/// The Appointments List sub-screen.
/// ********************************************************************************************************************
class AppointmentsList extends StatelessWidget {

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    print("## AppointmentssList.build()");

    // The list of dates with appointments.
    EventList<Event> _markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(decoration: BoxDecoration(color: Colors.blue))));
    }

    // Return widget.
    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(builder:
            (BuildContext inContext, Widget? inChild,
                AppointmentsModel inModel) {
          return Scaffold(
              // Add appointment.
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    appointmentsModel.entityBeingEdited = Appointment();
                    DateTime now = DateTime.now();
                    appointmentsModel.entityBeingEdited.apptDate =
                        "${now.year},${now.month},${now.day}";
                    appointmentsModel.setChosenDate(
                        DateFormat.yMMMMd("en_US").format(now.toLocal()));
                    appointmentsModel.setApptTime("");
                    appointmentsModel.setStackIndex(1);
                  }),
              body: Column(children: [
                Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CalendarCarousel<Event>(
                            thisMonthDayBorderColor: Colors.grey,
                            daysHaveCircularBorder: false,
                            markedDatesMap: _markedDateMap,
                            onDayPressed:
                                (DateTime inDate, List<Event> inEvents) {
                              _showAppointments(inDate, inContext);
                            })))
              ]));
        }));
  }

  /// Show a bottom sheet to see the appointments for the selected day.
  ///
  /// @param inDate    The date selected.
  /// @param inContext The build context of the parent widget.
  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    print(
        "## AppointmentsList._showAppointments(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})");

    print(
        "## AppointmentsList._showAppointments(): appointmentsModel.entityList.length = "
        "${appointmentsModel.entityList.length}");
    print(
        "## AppointmentsList._showAppointments(): appointmentsModel.entityList = "
        "${appointmentsModel.entityList}");

    showModalBottomSheet(
        context: inContext,
        builder: (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
              model: appointmentsModel,
              child: ScopedModelDescendant<AppointmentsModel>(builder:
                  (BuildContext inContext, Widget? inChild,
                      AppointmentsModel inModel) {
                return Scaffold(
                    body: Container(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: GestureDetector(
                                child: Column(children: [
                              Text(
                                  DateFormat.yMMMMd("en_US")
                                      .format(inDate.toLocal()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(inContext).accentColor,
                                      fontSize: 24)),
                              Divider(),
                              Expanded(
                                  child: ListView.builder(
                                      key: UniqueKey(),
                                      itemCount:
                                          appointmentsModel.entityList.length,
                                      itemBuilder: (BuildContext inBuildContext,
                                          int inIndex) {
                                        Appointment appointment =
                                            appointmentsModel
                                                .entityList[inIndex];
                                        print(
                                            "## AppointmentsList._showAppointments().ListView.builder(): "
                                            "appointment = $appointment");
                                        // Filter out any appointment that isn't for the specified date.
                                        if (appointment.apptDate !=
                                            "${inDate.year},${inDate.month},${inDate.day}") {
                                          return Container(height: 0);
                                        }
                                        print(
                                            "## AppointmentsList._showAppointments().ListView.builder(): "
                                            "INCLUDING appointment = $appointment");
                                        // If the appointment has a time, format it for display.
                                        String apptTime = "";
                                        if (appointment.apptTime != "") {
                                          List timeParts =
                                              appointment.apptTime.split(",");
                                          TimeOfDay at = TimeOfDay(
                                              hour: int.parse(timeParts[0]),
                                              minute: int.parse(timeParts[1]));
                                          apptTime =
                                              " (${at.format(inContext)})";
                                        }
                                        // Return a widget for the appointment since it's for the correct date.
                                        return Slidable(
                                            startActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              extentRatio: 0.25,
                                              children: [
                                                SlidableAction(
                                                  label: 'Edit',
                                                  backgroundColor: Colors.blue,
                                                  icon: Icons.edit,
                                                  onPressed: (inContext) async {_editAppointment(inContext, appointment);},
                                                ),
                                              ],
                                            ),
                                            endActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              extentRatio: 0.25,
                                              children: [
                                                SlidableAction(
                                                  label: 'Delete',
                                                  backgroundColor: Colors.red,
                                                  icon: Icons.delete,
                                                  onPressed: (inContext) {_deleteAppointment(inBuildContext, appointment);},
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                                margin : EdgeInsets.only(bottom : 8),
                                                color : Colors.grey.shade300,
                                                child : ListTile(
                                                    title : Text("${appointment.title}$apptTime"),
                                                    subtitle : appointment.description == null ?
                                                    null : Text("${appointment.description}"),
                                                    // Edit existing appointment.
                                                    onTap : () async { _editAppointment(inContext, appointment); }
                                                )
                                            )
                                        );
                                      }))
                            ])))));
              }));
        });
  }

  /// Handle taps on an appointment to trigger editing.
  ///
  /// @param inContext     The BuildContext of the parent widget.
  /// @param inAppointment The Appointment being edited.
  void _editAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    print(
        "## AppointmentsList._editAppointment(): inAppointment = $inAppointment");

    // Get the data from the database and send to the edit view.
    appointmentsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(inAppointment.id as int);
    // Parse out the apptDate and apptTime, if any, and set them in the model
    // for display.
    if (appointmentsModel.entityBeingEdited.apptDate == "") {
      appointmentsModel.setChosenDate("");
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      appointmentsModel
          .setChosenDate(DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
      if (appointmentsModel.entityBeingEdited.apptTime == "") {
        appointmentsModel.setApptTime("");
      } else {
        List timeParts =
            appointmentsModel.entityBeingEdited.apptTime.split(",");
        TimeOfDay apptTime = TimeOfDay(
            hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        appointmentsModel.setApptTime(apptTime.format(inContext));
      }
      appointmentsModel.setStackIndex(1);
      Navigator.pop(inContext);
    }
  }

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext     The parent build context.
  /// @param  inAppointment The appointment (potentially) being deleted.
  /// @return               Future.
  Future<void> _deleteAppointment(
      BuildContext inContext, Appointment inAppointment) {
    print(
        "## AppointmentsList._deleteAppointment(): inAppointment = $inAppointment");

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Appointment"),
            content: Text(
                "Are you sure you want to delete ${inAppointment.description}?"),
            actions: [
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    // Just hide dialog.
                    Navigator.of(inAlertContext).pop();
                  }),
              TextButton(
                  child: Text("Delete"),
                  onPressed: () async {
                    // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                    await AppointmentsDBWorker.db
                        .delete(inAppointment.id as int);
                    Future(() {
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                          content: Text("Appointment deleted"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2)));
                    });
                    // Reload data from database to update list.
                    appointmentsModel.loadData(
                        "appointments", AppointmentsDBWorker.db);
                  })
            ],
          );
        });
  }
}
