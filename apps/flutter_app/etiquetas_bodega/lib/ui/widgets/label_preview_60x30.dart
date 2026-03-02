import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class LabelPreview60x30 extends StatelessWidget {
  /// Datos
  final String name;
  final String code;

  /// Config física
  final double widthMm; // 60
  final double heightMm; // 30
  final double marginMm; // 5

  /// Preview scaling (px por mm)
  final double pxPerMm;

  /// Mostrar guías (margen)
  final bool showGuides;

  const LabelPreview60x30({
    super.key,
    required this.name,
    required this.code,
    this.widthMm = 60,
    this.heightMm = 30,
    this.marginMm = 5,
    this.pxPerMm = 8, // recomendado: 8 (o 10 si quieres aún más grande)
    this.showGuides = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Tamaño total de etiqueta en px
    final labelW = widthMm * pxPerMm;
    final labelH = heightMm * pxPerMm;

    // Margen en px
    final m = marginMm * pxPerMm;

    // Área útil en px (50x20mm -> 400x160px si pxPerMm=8)
    final innerW = labelW - (m * 2);
    final innerH = labelH - (m * 2);

    // Distribución vertical en mm dentro del área útil 20mm:
    // Nombre 6mm, Barcode 10mm, Código 4mm
    final nameH = 6 * pxPerMm;
    final barcodeH = 10 * pxPerMm;
    final codeH = 4 * pxPerMm;

    return Center(
      child: SizedBox(
        width: labelW,
        height: labelH,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: theme.dividerColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: showGuides
                ? _MarginGuidePainter(marginPx: m, color: theme.dividerColor)
                : null,
            child: Padding(
              padding: EdgeInsets.all(m),
              child: SizedBox(
                width: innerW,
                height: innerH,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NOMBRE (6mm)
                    SizedBox(
                      height: nameH,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize:
                                12, // se ajusta visualmente; no “mm exacto”
                            fontWeight: FontWeight.w600,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),

                    // BARCODE (10mm)
                    SizedBox(
                      height: barcodeH,
                      child: Center(
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: code,
                          drawText: false,
                          width: innerW,
                          height: barcodeH,
                          errorBuilder: (context, error) => Center(
                            child: Text(
                              'Barcode inválido',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // CÓDIGO (4mm)
                    SizedBox(
                      height: codeH,
                      child: Center(
                        child: Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarginGuidePainter extends CustomPainter {
  final double marginPx;
  final Color color;

  _MarginGuidePainter({required this.marginPx, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Rect.fromLTWH(
      marginPx,
      marginPx,
      size.width - marginPx * 2,
      size.height - marginPx * 2,
    );

    // Guía simple (sin punteado para no complicar)
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _MarginGuidePainter oldDelegate) {
    return oldDelegate.marginPx != marginPx || oldDelegate.color != color;
  }
}
