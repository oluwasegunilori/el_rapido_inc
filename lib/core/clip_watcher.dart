import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClipState extends Equatable {
  final String? link;

  const ClipState({this.link});

  @override
  List<Object?> get props => [link];
}

class ClipBloc extends Cubit<ClipState> {
  ClipBloc() : super(ClipState());

  void setLink(String? link) {
    emit(ClipState(link: link));
  }
}
