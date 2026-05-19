// Constantes globales de la aplicación centralizadas para evitar duplicación.
// Incluye departamentos de Honduras y tipos de propiedades disponibles.

/// Constantes centralizadas de la aplicación para eliminar duplicación.
class AppConstants {
  AppConstants._(); // Prevenir instanciación

  /// Departamentos de Honduras para selección de ubicación.
  static const List<String> departments = [
    'Atlántida', 'Choluteca', 'Colón', 'Comayagua', 'Copán',
    'Cortés', 'El Paraíso', 'Francisco Morazán', 'Gracias a Dios', 'Intibucá',
    'Islas de la Bahía', 'La Paz', 'Lempira', 'Ocotepeque', 'Olancho',
    'Santa Bárbara', 'Valle', 'Yoro',
  ];

  /// Tipos de propiedad soportados.
  static const List<String> propertyTypes = [
    'Casa', 'Apartamento', 'Terreno', 'Edificio Comercial', 'Local', 'Oficina', 'Otro',
  ];
}
