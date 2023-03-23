import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsList.dart';
import 'AppointmentsEntry.dart';
import 'AppointmentsModel.dart'
    show Appointment, Appointments, AppointmentsModel, appointmentsModel;

/// ********************************************************************************************************************
/// The Appointments screen.
/// ********************************************************************************************************************
class Appointments extends StatelessWidget {
  /// Constructor.
  Appointments() {
    print("## Appointments.constructor");

    // Initial load of data.
    appointmentsModel.entityBeingEdited = Appointment();
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext context) {
    print("## Appointments.build()");

    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(builder:
            (BuildContext inContext, Widget? inChild,
                AppointmentsModel inModel) {
          return IndexedStack(
              index: inModel.stackIndex,
              children: [AppointmentsList(), AppointmentsEntry()]);
        }));
  }
}
