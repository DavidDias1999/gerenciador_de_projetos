import 'package:uuid/uuid.dart';

import '../../domain/models/task_model.dart';
import '../../domain/models/step_model.dart';

final uuid = Uuid();

List<Step> createDefaultSteps() {
  return [
    Step(
      id: uuid.v4(),
      title: 'Etapa 1',
      tasks: [
        Task(id: uuid.v4(), title: 'Tarefa 1'),
        Task(id: uuid.v4(), title: 'Tarefa 2'),
      ],
    ),
    Step(
      id: uuid.v4(),
      title: 'Etapa 2',
      tasks: [
        Task(id: uuid.v4(), title: 'Tarefa 1'),
        Task(id: uuid.v4(), title: 'Tarefa 2'),
      ],
    ),
  ];
}
