import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleCalendarCard extends StatelessWidget {
  final int cycleDay;

  const CycleCalendarCard({
    super.key,
    required this.cycleDay,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysInMonth =
        DateUtils.getDaysInMonth(today.year, today.month);

    final firstDay =
        DateTime(today.year, today.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE4EC), // soft pink
            Color(0xFFFFF1F5), // peach pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🌸 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _monthName(today.month),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              _phaseChip(),
            ],
          ),

          const SizedBox(height: 12),

          // 📅 WEEK LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["S", "M", "T", "W", "T", "F", "S"]
                .map((e) => Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          // 📅 CALENDAR GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDay - 1,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (_, index) {
              if (index < firstDay - 1) {
                return const SizedBox();
              }

              final day = index - firstDay + 2;
              final isToday = day == today.day;

              return Container(
                decoration: BoxDecoration(
                  gradient: isToday
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFFA6C9),
                            Color(0xFFFF6FA3),
                          ],
                        )
                      : null,
                  color:
                      isToday ? null : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.4),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🌙 PHASE CHIP
  Widget _phaseChip() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _phaseColor(cycleDay).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _phaseName(cycleDay),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  // 🌙 PHASE LOGIC
  String _phaseName(int day) {
    if (day <= 5) return "Menstrual";
    if (day <= 13) return "Follicular";
    if (day <= 16) return "Ovulation";
    return "Luteal";
  }

  Color _phaseColor(int day) {
    if (day <= 5) return Colors.redAccent;
    if (day <= 13) return Colors.orange;
    if (day <= 16) return Colors.pink;
    return Colors.purple;
  }

  String _monthName(int month) {
    const months = [
      "", "January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December"
    ];
    return months[month];
  }
}