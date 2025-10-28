import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'key')
enum ProjectComplexity {
  baixa(key: 'baixa', displayName: 'Baixa'),
  media(key: 'media', displayName: 'Média'),
  alta(key: 'alta', displayName: 'Alta');

  const ProjectComplexity({
    required this.key,
    required this.displayName,
  });

  final String key;
  final String displayName;
}
