
// Java HTTP Server Benchmark (Optimized JVM Args)
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.lang.management.ManagementFactory;
import java.util.concurrent.Executors;

public class Server {
    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(3003), 0);

        server.createContext("/", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) throws IOException {
                String response = String.format(
                        "{\"message\":\"Hello from Java (Optimized)\",\"timestamp\":%d}",
                        System.currentTimeMillis());

                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, response.length());

                OutputStream os = exchange.getResponseBody();
                os.write(response.getBytes());
                os.close();
            }
        });

        // Use Virtual Threads for maximum efficiency (Project Loom)
        server.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
        server.start();

        String pid = ManagementFactory.getRuntimeMXBean().getName().split("@")[0];
        System.out.println("Java server running on http://localhost:3003");
        System.out.println("PID: " + pid);
    }
}
