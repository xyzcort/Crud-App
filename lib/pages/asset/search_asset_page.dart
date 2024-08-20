import 'dart:convert';
import 'package:app_assets/configure/app_constant.dart';
import 'package:app_assets/models/asset_model.dart';
import 'package:d_method/d_method.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchAssetPage extends StatefulWidget {
  const SearchAssetPage({super.key});

  @override
  State<SearchAssetPage> createState() => _SearchAssetPageState();
}

class _SearchAssetPageState extends State<SearchAssetPage> {
  List<AssetModel> assets = [];
  final edtSearch = TextEditingController();

  // Fungsi untuk melakukan pencarian aset berdasarkan kata kunci
  searchAsset() async {
    if (edtSearch.text == '') return;

    assets.clear(); // Mengosongkan daftar aset untuk pencarian baru
    setState(() {}); // Memperbarui tampilan

    Uri url = Uri.parse(
      '${AppConstant.baseURL}/assets/search.php',
    );

    try {
      final response = await http.post(url, body: {
        'search': edtSearch.text,
      });
      DMethod.printResponse(response); // Mencetak respons HTTP untuk debugging

      Map resBody = jsonDecode(response.body);
      bool success = resBody['success'] ?? false;
      if (success) {
        List data = resBody['data'];
        assets = data
            .map((e) => AssetModel.fromJson(e))
            .toList(); // Mengubah data JSON menjadi daftar objek AssetModel
      }
      setState(() {}); // Memperbarui tampilan setelah mendapatkan data berhasil
    } catch (e) {
      DMethod.printTitle(
        'catch',
        e.toString(),
      ); // Mencetak pesan kesalahan yang mungkin terjadi dalam blok catch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: edtSearch,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search here..',
              isDense: true,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              searchAsset(); // Memanggil fungsi pencarian aset saat tombol pencarian ditekan
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: assets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Empty'),
                  IconButton(
                    onPressed: () {
                      searchAsset(); // Memanggil kembali fungsi pencarian aset saat tombol refresh ditekan
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                searchAsset(); // Memanggil kembali fungsi pencarian saat melakukan gesture refresh
              },
              child: GridView.builder(
                itemCount: assets.length,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  AssetModel item = assets[index];
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${AppConstant.baseURL}/image/${item.image}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          item.type,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
