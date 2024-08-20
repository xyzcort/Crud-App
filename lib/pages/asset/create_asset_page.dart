import 'dart:convert';
import 'dart:typed_data';

import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../configure/app_constant.dart';

class CreateAssetPage extends StatefulWidget {
  const CreateAssetPage({Key? key}) : super(key: key);

  @override
  State<CreateAssetPage> createState() => _CreateAssetPageState();
}

class _CreateAssetPageState extends State<CreateAssetPage> {
  final formkey = GlobalKey<FormState>();
  final edtName = TextEditingController();
  List<String> types = [
    'Transportasi',
    'Home',
    'Place',
    'Other',
  ];
  String type = 'Place';
  // ignore: non_constant_identifier_names
  String? ImageName;
  Uint8List? imageByte;

  // Memilih gambar dari kamera atau galeri
  pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      ImageName = picked.name;
      imageByte = await picked.readAsBytes();
      setState(() {});
    }
    DMethod.printBasic('imageName: $ImageName');
  }

  // Menyimpan aset baru ke server
  save() async {
    bool isValidInput = formkey.currentState!.validate();
    if (!isValidInput) return;

    if (imageByte == null) {
      DInfo.toastError(
          'Image required'); // Pesan error jika gambar belum dipilih
      return;
    }
    Uri url = Uri.parse(
      '${AppConstant.baseURL}/assets/create.php',
    );

    try {
      final response = await http.post(url, body: {
        'name': edtName.text,
        'type': type,
        'image': ImageName,
        'base64code': base64Encode(imageByte as List<int>),
      });
      DMethod.printResponse(response);

      Map resBody = jsonDecode(response.body);
      bool success = resBody['success'] ?? false;
      if (success) {
        DInfo.toastSuccess('Success Create Asset');
        // ignore: use_build_context_synchronously
        Navigator.pop(
            context); // Kembali ke halaman sebelumnya setelah berhasil
      } else {
        DInfo.toastError('Failed Create Asset');
      }
    } catch (e) {
      DMethod.printTitle(
        'catch',
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Asset'),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DInput(
              controller: edtName,
              title: 'Name',
              hint: 'Example name',
              fillColor: Colors.white,
              validator: (input) =>
                  input == '' ? "Name required" : null, // validasi input nama
              radius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Dropdown untuk memilih aset
            DropdownButtonFormField(
              value: type,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              items: types.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                    setState(() {});
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Image',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Tampilan gambar yang dipilih
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: imageByte == null
                    ? const Text('Required')
                    : Image.memory(imageByte!),
              ),
            ),
            ButtonBar(
              children: [
                // Memilih gambar dari kamera
                OutlinedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                // Memilih gambar dari galeri
                OutlinedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Galery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Menyimpan aset baru
            ElevatedButton(
              onPressed: () {
                save();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
