import 'package:image_picker/image_picker.dart';
import '../../controllers/base_controller.dart';

Future<UploadFile?> pickUploadFile() async {
  final xfile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (xfile == null) return null;
  return UploadFile(await xfile.readAsBytes(), xfile.name);
}
