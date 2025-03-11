import 'package:data_table_2/data_table_2.dart';
import 'package:el_rapido_inc/auth/presentation/logout.dart';
import 'package:el_rapido_inc/core/data/model/user.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/core/screen_calc.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_bloc.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_event.dart';
import 'package:el_rapido_inc/dashboard/user/presentation/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserBloc userbloc = getIt<UserBloc>();
    userbloc.add(FetchUsers());
    return BlocProvider(
      create: (context) => userbloc,
      child: Scaffold(
        appBar: !isMobile(context)
            ? AppBar(
                title: const Text('Users'),
                actions: [buildLogoutButton(context)],
                elevation: 4,
              )
            : null,
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary.withAlpha(150),
                  ),
                  border: TableBorder.all(color: Colors.grey, width: 1),
                  columns: const [
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Activated')),
                    DataColumn(label: Text('Role')),
                  ],
                  rows: state.users
                      .map((user) => DataRow(cells: [
                            DataCell(Text(user.firstName)),
                            DataCell(Text(user.lastName)),
                            DataCell(Text(user.email)),
                            DataCell(Switch(
                              value: user.activated,
                              onChanged: (value) {
                                context.read<UserBloc>().add(UpdateUser(
                                    user.copyWith(activated: value)));
                              },
                            )),
                            DataCell(
                              DropdownButton<UserRole>(
                                value: user.role,
                                onChanged: (newRole) {
                                  if (newRole != null) {
                                    context.read<UserBloc>().add(UpdateUser(
                                        user.copyWith(role: newRole)));
                                  }
                                },
                                items: UserRole.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role.name),
                                  );
                                }).toList(),
                              ),
                            ),
                          ]))
                      .toList(),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class DeleteUser {}
