import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class GenerateurLogs {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: GenerateurLogs <matricule> <nombre>");
            System.exit(1);
        }

        String matricule = args[0];
        int nombre;

        try {
            nombre = Integer.parseInt(args[1]);
        } catch (NumberFormatException e) {
            System.err.println("Le nombre doit être un entier.");
            System.exit(1);
            return;
        }

        Random random = new Random();
        String[] niveaux = {"INFO", "WARN", "ERROR"};
        DateTimeFormatter format =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        try (BufferedWriter writer =
                 new BufferedWriter(new FileWriter("logs/access.log"))) {
            for (int i = 0; i < nombre; i++) {
                String date = LocalDateTime.now().format(format);
                String niveau = niveaux[random.nextInt(niveaux.length)];
                writer.write(date + " " + niveau + " " + matricule);
                writer.newLine();
            }
        } catch (IOException e) {
            System.err.println("Erreur : " + e.getMessage());
            System.exit(1);
        }
    }
}
