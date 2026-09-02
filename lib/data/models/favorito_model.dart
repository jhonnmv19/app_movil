// lib/data/models/favorito_model.dart

import 'establecimiento_model.dart';

class FavoritoModel {
  final int id;
  final int comensalId;
  final int establecimientoId;
  final DateTime fechaAgregado;
  
  // Relación opcional para cargar los detalles del establecimiento guardado
  final EstablecimientoModel? establecimiento;

  FavoritoModel({
    required this.id,
    required this.comensalId,
    required this.establecimientoId,
    required this.fechaAgregado,
    this.establecimiento,
  });

  /// Crea una instancia a partir del JSON que retorna Supabase
  factory FavoritoModel.fromJson(Map<String, dynamic> json) {
    return FavoritoModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.parse(json['id'].toString()),
      comensalId: json['comensal_id'] is int 
          ? json['comensal_id'] 
          : int.parse(json['comensal_id'].toString()),
      establecimientoId: json['establecimiento_id'] is int 
          ? json['establecimiento_id'] 
          : int.parse(json['establecimiento_id'].toString()),
      fechaAgregado: json['fecha_agregado'] != null
          ? DateTime.parse(json['fecha_agregado'])
          : DateTime.now(),
      establecimiento: json['establecimientos_r_sabor'] != null
          ? EstablecimientoModel.fromJson(
              json['establecimientos_r_sabor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Convierte la instancia a un JSON para insertar en Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'comensal_id': comensalId,
      'establecimiento_id': establecimientoId,
      'fecha_agregado': fechaAgregado.toIso8601String(),
    };
  }

  /// Método de conveniencia para crear copias modificadas
  FavoritoModel copyWith({
    int? id,
    int? comensalId,
    int? establecimientoId,
    DateTime? fechaAgregado,
    EstablecimientoModel? establecimiento,
  }) {
    return FavoritoModel(
      id: id ?? this.id,
      comensalId: comensalId ?? this.comensalId,
      establecimientoId: establecimientoId ?? this.establecimientoId,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
      establecimiento: establecimiento ?? this.establecimiento,
    );
  }
}