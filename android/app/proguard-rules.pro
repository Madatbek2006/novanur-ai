# ML Kit тянет модуль связи с Firebase, а firebase-iid из сборки исключён
# намеренно (см. configurations.exclude в build.gradle.kts). Класс нужен
# только для удалённых моделей, которых у нас нет, поэтому R8 про него
# просто молчит вместо того, чтобы валить сборку.
-dontwarn com.google.firebase.iid.FirebaseInstanceId

# Плагин распознавания текста в своём initialize перечисляет все письменности
# сразу, а в сборке оставлена только латиница — единственная, которую просит
# приложение (scan_text_page.dart). Классов остальных в сборке нет, и R8 об
# этом предупреждает; путь к ним не исполняется, поэтому предупреждение гасим.
#
# ВАЖНО: если когда-нибудь понадобится распознавать другую письменность,
# сначала вернуть её зависимость в build.gradle.kts — иначе приложение
# упадёт в этом месте уже во время работы, а не на сборке.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
