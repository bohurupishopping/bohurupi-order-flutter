import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderFormWidget extends StatefulWidget {
  final Map<String, dynamic> initialOrderDetails;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isEditMode;

  const OrderFormWidget({
    super.key, 
    required this.initialOrderDetails,
    required this.onSubmit,
    this.isEditMode = false,
  });

  @override
  _OrderFormWidgetState createState() => _OrderFormWidgetState();
}

class _OrderFormWidgetState extends State<OrderFormWidget> {
  late Map<String, dynamic> _orderDetails;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Create a deep copy of initial order details
    _orderDetails = Map<String, dynamic>.from(widget.initialOrderDetails);
    
    // Ensure dropdown values are valid
    _ensureValidDropdownValues();
  }

  void _ensureValidDropdownValues() {
    // Status validation
    final statusOptions = ['Pending', 'Delivered'];
    if (!statusOptions.contains(_orderDetails['status'])) {
      _orderDetails['status'] = statusOptions.first;
    }

    // Order Status validation
    final orderStatusOptions = ['Prepaid', 'COD'];
    if (!orderStatusOptions.contains(_orderDetails['orderstatus'])) {
      _orderDetails['orderstatus'] = orderStatusOptions.first;
    }

    // Product Details validation
    final productDetailsOptions = ['Pure Cotton', 'Full Sleeve', 'Poly Cotton', 'Polyester', 'Mobile Cover', 'Coffee Mug'];
    if (!productDetailsOptions.contains(_orderDetails['details'])) {
      _orderDetails['details'] = productDetailsOptions.first;
    }

    // Colour validation
    final colourOptions = ['Black', 'White', 'Blue', 'Green', 'Maroon', 'Yellow', 'None'];
    if (!colourOptions.contains(_orderDetails['colour'])) {
      _orderDetails['colour'] = colourOptions.first;
    }
  }

  Widget _buildField({
    required String label,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.purple[400]),
              const SizedBox(width: 8),
              Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_orderDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Status',
                  icon: Icons.pending_actions,
                  child: DropdownButtonFormField<String>(
                    key: UniqueKey(), // Add unique key to prevent duplicate value issue
                    value: _orderDetails['status'],
                    decoration: _inputDecoration('Select status'),
                    items: ['Pending', 'Delivered'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _orderDetails['status'] = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  label: 'Order Status',
                  icon: Icons.shopping_cart,
                  child: DropdownButtonFormField<String>(
                    key: UniqueKey(), // Add unique key to prevent duplicate value issue
                    value: _orderDetails['orderstatus'],
                    decoration: _inputDecoration('Select order status'),
                    items: ['Prepaid', 'COD'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _orderDetails['orderstatus'] = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ),
            ],
          ),
          _buildField(
            label: 'Customer Name',
            icon: Icons.person,
            child: TextFormField(
              initialValue: _orderDetails['name'],
              decoration: _inputDecoration('Enter customer name'),
              style: GoogleFonts.poppins(fontSize: 12),
              onSaved: (v) => _orderDetails['name'] = v,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Product Details',
                  icon: Icons.inventory_2,
                  child: DropdownButtonFormField<String>(
                    key: UniqueKey(), // Add unique key to prevent duplicate value issue
                    value: _orderDetails['details'],
                    decoration: _inputDecoration('Select product details'),
                    items: ['Pure Cotton', 'Full Sleeve', 'Poly Cotton', 
                           'Polyester', 'Mobile Cover', 'Coffee Mug']
                      .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _orderDetails['details'] = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  label: 'Colour',
                  icon: Icons.color_lens,
                  child: DropdownButtonFormField<String>(
                    key: UniqueKey(), // Add unique key to prevent duplicate value issue
                    value: _orderDetails['colour'],
                    decoration: _inputDecoration('Select colour'),
                    items: ['Black', 'White', 'Blue', 'Green', 
                           'Maroon', 'Yellow', 'None']
                      .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _orderDetails['colour'] = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Size/Model',
                  icon: Icons.straighten,
                  child: TextFormField(
                    initialValue: _orderDetails['size'],
                    decoration: _inputDecoration('Enter size or model'),
                    style: GoogleFonts.poppins(fontSize: 12),
                    onSaved: (v) => _orderDetails['size'] = v,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  label: 'Quantity',
                  icon: Icons.numbers,
                  child: TextFormField(
                    initialValue: _orderDetails['qty'].toString(),
                    decoration: _inputDecoration('Enter quantity'),
                    style: GoogleFonts.poppins(fontSize: 12),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _orderDetails['qty'] = int.tryParse(v ?? '') ?? 1,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(v!) == null || int.parse(v) <= 0) {
                        return 'Enter valid quantity';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          _buildField(
            label: 'Image URL',
            icon: Icons.image,
            child: TextFormField(
              initialValue: _orderDetails['image'],
              decoration: _inputDecoration('Enter image URL'),
              style: GoogleFonts.poppins(fontSize: 12),
              onSaved: (v) => _orderDetails['image'] = v ?? '',
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
          _buildField(
            label: 'Design URL',
            icon: Icons.download,
            child: TextFormField(
              initialValue: _orderDetails['downloaddesign'],
              decoration: _inputDecoration('Enter design URL'),
              style: GoogleFonts.poppins(fontSize: 12),
              onSaved: (v) => _orderDetails['downloaddesign'] = v,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.pink[400]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple[200]!,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.isEditMode ? 'Update Order' : 'Submit Order',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
