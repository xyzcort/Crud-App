import 'dart:convert';

import 'package:app_assets/configure/app_constant.dart';
import 'package:app_assets/models/asset_model.dart';
import 'package:app_assets/pages/asset/search_asset_page.dart';
import 'package:app_assets/pages/asset/update_asset_page.dart';
import 'package:app_assets/pages/user/login_page.dart';
import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:http/http.dart' as http;
import 'package:app_assets/pages/asset/create_asset_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AssetModel> assets = [];

  // Fungsi untuk membaca daftar aset dari server
  readAssets() async {
    assets.clear();
    setState(() {});

    Uri url = Uri.parse(
      '${AppConstant.baseURL}/assets/read.php',
    );

    try {
      final response = await http.get(url);
      DMethod.printResponse(response); // Mencetak respons HTTP untuk debugging

      Map resBody = jsonDecode(response.body);
      bool success = resBody['success'] ?? false;
      if (success) {
        List data = resBody['data'];
        assets = data
            .map((e) => AssetModel.fromJson(e))
            .toList(); // Mengubah data JSON menjadi daftar objek AssetModel
      }
      setState(() {});
    } catch (e) {
      DMethod.printTitle(
        'catch',
        e.toString(),
      ); // Mencetak pesan kesalahan yang terjadi dalam blok catch
    }
  }

  // Fungsi untuk menampilkan menu saat item aset di-tap
  showMenuItem(AssetModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(item.name),
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateAssetPage(
                      oldAsset: item,
                    ),
                  ),
                ).then(
                  (value) => readAssets(),
                );
              },
              horizontalTitleGap: 0,
              leading: const Icon(
                Icons.edit,
                color: Colors.amber,
              ),
              title: const Text('Update'),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                deleteAsset(item);
              },
              horizontalTitleGap: 0,
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus aset
  deleteAsset(AssetModel item) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Delete',
      'Yakin untuk menghapus ${item.name}?',
    );
    if (yes ?? false) {
      Uri url = Uri.parse(
        '${AppConstant.baseURL}/assets/delete.php',
      );

      try {
        final response = await http.post(url, body: {
          'id': item.id,
          'image': item.image,
        });
        DMethod.printResponse(response);

        Map resBody = jsonDecode(response.body);
        bool success = resBody['success'] ?? false;
        if (success) {
          DInfo.toastSuccess('Success Delete Asset');
          readAssets(); // Refresh daftar aset setelah menghapus
        } else {
          DInfo.toastError('Failed Delete Asset');
        }
      } catch (e) {
        DMethod.printTitle(
          'catch',
          e.toString(),
        ); // Mencetak pesan kesalahan yang terjadi dalam blok catch
      }
    }
  }

  @override
  void initState() {
    readAssets(); // Memanggil fungsi untuk membaca daftar aset saat halaman diinisialisasi
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton(
          onSelected: (value) {
            if (value == 'Logout') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Logout',
              child: Text('Logout'),
            )
          ],
        ),
        title: const Text(AppConstant.appName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchAssetPage(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAssetPage(),
            ),
          ).then((value) =>
              readAssets()); // Menjalankan readAssets() setelah kembali dari CreateAssetPage
        },
        child: const Icon(Icons.add),
      ),
      body: assets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Empty'),
                  IconButton(
                    onPressed: () {
                      // Fungsi untuk melakukan refresh ketika tombol ditekan
                      readAssets();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                readAssets(); // Menjalankan fungsi readAssets() saat melakukan refresh
              },
              child: GridView.builder(
                // Widget untuk menampilkan daftar aset dalam bentuk GridView
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue[50],
                              child: InkWell(
                                onTap: () {
                                  showMenuItem(item);
                                },
                                splashColor: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          ],
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
