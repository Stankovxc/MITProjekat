import 'package:discover_herceg_novi/models/season_price_model.dart';
import 'package:discover_herceg_novi/services/season_price_service.dart';
import 'package:flutter/material.dart';

class AdminSeasonPricesScreen extends StatefulWidget {
  final String apartmentId;
  final double basePrice;

  const AdminSeasonPricesScreen({
    super.key,
    required this.apartmentId,
    required this.basePrice,
  });

  @override
  State<AdminSeasonPricesScreen> createState() =>
      _AdminSeasonPricesScreenState();
}

class _AdminSeasonPricesScreenState extends State<AdminSeasonPricesScreen> {
  final SeasonPriceService _seasonPriceService = SeasonPriceService();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sezonske cijene'),
        backgroundColor: const Color(0xFF00A8CC),
      ),
      body: StreamBuilder<List<SeasonPriceModel>>(
        stream: _seasonPriceService.getSeasonPrices(widget.apartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Greška pri učitavanju cijena:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final seasonPrices = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasePriceCard(),

                const SizedBox(height: 20),

                _buildAddPriceForm(),

                const SizedBox(height: 28),

                const Text(
                  'Definisani periodi',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                if (seasonPrices.isEmpty)
                  _buildEmptyState()
                else
                  ...seasonPrices.map(
                    (season) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildSeasonCard(season),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasePriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF00A8CC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.euro_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Osnovna cijena apartmana',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.basePrice.toStringAsFixed(2)} € / noć',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPriceForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 9, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dodaj sezonsku cijenu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Naziv perioda',
              hintText: 'Na primjer: Ljetnja sezona',
              prefixIcon: const Icon(Icons.label_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cijena po noći',
              hintText: 'Na primjer: 120',
              prefixIcon: const Icon(Icons.euro),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  title: 'Početak',
                  value: _startDate,
                  icon: Icons.calendar_today_rounded,
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelector(
                  title: 'Kraj',
                  value: _endDate,
                  icon: Icons.event_available_rounded,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isSaving ? 'ČUVANJE...' : 'SAČUVAJ CIJENU',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSaving ? null : _saveSeasonPrice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00A8CC)),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value == null ? 'Izaberi datum' : _formatDate(value),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonCard(SeasonPriceModel season) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.orange),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatDate(season.startDate)} - '
                  '${_formatDate(season.endDate)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  '${season.pricePerNight.toStringAsFixed(2)} € / noć',
                  style: const TextStyle(
                    color: Color(0xFF00A8CC),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Obriši cjenovnik',
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () {
              _confirmDelete(season);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.price_change_outlined,
            size: 56,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 10),
          const Text(
            'Nema sezonskih cijena',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Za sve datume trenutno se koristi osnovna cijena.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
    );

    if (selectedDate == null) return;

    setState(() {
      _startDate = selectedDate;

      if (_endDate != null && _endDate!.isBefore(selectedDate)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final firstAllowedDate = _startDate ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
    );

    if (selectedDate == null) return;

    setState(() {
      _endDate = selectedDate;
    });
  }

  Future<void> _saveSeasonPrice() async {
    final title = _titleController.text.trim();

    final priceText = _priceController.text.trim().replaceAll(',', '.');

    final price = double.tryParse(priceText);

    if (title.isEmpty) {
      _showMessage('Unesite naziv perioda.');
      return;
    }

    if (price == null || price <= 0) {
      _showMessage('Unesite ispravnu cijenu.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showMessage('Izaberite početni i krajnji datum.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _seasonPriceService.addSeasonPrice(
        apartmentId: widget.apartmentId,
        title: title,
        startDate: _startDate!,
        endDate: _endDate!,
        pricePerNight: price,
      );

      if (!mounted) return;

      _titleController.clear();
      _priceController.clear();

      setState(() {
        _startDate = null;
        _endDate = null;
      });

      _showMessage('Sezonska cijena je sačuvana.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(SeasonPriceModel season) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.red,
            size: 54,
          ),
          title: const Text('Brisanje cijene', textAlign: TextAlign.center),
          content: Text(
            'Da li želite da obrišete period '
            '"${season.title}"?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Ne'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _seasonPriceService.deleteSeasonPrice(season.id);

      if (!mounted) return;

      _showMessage('Period je obrisan.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}.';
  }
}
