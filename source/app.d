import vibe.d; 
import vibe.core.file;

void uploadFile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
	auto pf = "file" in req.files;
	enforce(pf !is null, "No file uploaded!");
	try moveFile(pf.tempPath, Path("./public/song.mp3"));
	catch (Exception e) {
		logWarn("Failed to move file to destination folder: %s", e.msg);
		logInfo("Performing copy+delete instead.");
		copyFile(pf.tempPath, Path("./public/song.mp3"));
	}
	res.redirect("/");
}

void main() {
	// Register web services
	auto router = new URLRouter;

	// Add static pages to router
	router.get("/", staticRedirect("/home.html"));
	router.post("/upload", &uploadFile);	

	// Add static files to server
	router.get("*", serveStaticFiles("public"));

	// Settings for Windows development and Ubuntu 20.04 EC2 deployment
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore;
	settings.port = 666;

	version(Windows) {
		settings.bindAddresses = ["127.0.0.1"];
	} else {
		settings.bindAddresses = ["::"];
	}

	auto listener = listenHTTP(settings, router);
	scope(exit) listener.stopListening();	
	runApplication();	
}
