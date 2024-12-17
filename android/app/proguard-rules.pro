# Preserve classes principais
-keep class br.com.mindcareapp.mindcare_app.** { *; }

# Preserve bibliotecas Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Preserve bibliotecas do Google
-keep class com.google.** { *; }
-dontwarn com.google.**

# Preserve bibliotecas comuns (exemplo: Gson, Retrofit)
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }

# Remova logs do Android em release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
