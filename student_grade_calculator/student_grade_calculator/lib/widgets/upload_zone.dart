import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UploadZone extends StatelessWidget {
  final String? fileName;
  final bool isLoading;
  final VoidCallback onTap;

  const UploadZone({
    super.key,
    this.fileName,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Excel File',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1A237E),
                  fontWeight: FontWeight.w600,
                )),
        const Gap(8),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 64,
            decoration: BoxDecoration(
              color: hasFile
                  ? Colors.green.shade50
                  : isLoading
                      ? Colors.grey.shade100
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile
                    ? Colors.green.shade400
                    : isLoading
                        ? Colors.grey.shade300
                        : const Color(0xFFBBDEFB),
                width: hasFile ? 2 : 1,
              ),
            ),
            child: isLoading
                ? const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        Gap(10),
                        Text('Parsing file...',
                            style: TextStyle(color: Color(0xFF1A237E))),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasFile
                            ? Icons.check_circle_outline
                            : Icons.upload_file_outlined,
                        color: hasFile
                            ? Colors.green.shade600
                            : const Color(0xFF1A237E),
                        size: 22,
                      ),
                      const Gap(10),
                      Flexible(
                        child: Text(
                          hasFile ? fileName! : 'Click to upload .xlsx / .xls',
                          style: TextStyle(
                            color: hasFile
                                ? Colors.green.shade700
                                : const Color(0xFF3949AB),
                            fontWeight: hasFile
                                ? FontWeight.w600
                                : FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (hasFile) ...[
                        const Gap(8),
                        Text('(tap to change)',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 11)),
                      ]
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
