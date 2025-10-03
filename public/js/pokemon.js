// Pokemon JavaScript functionality

// Share Pokemon function
window.sharePokemons = function (name, id) {
	if (navigator.share) {
		navigator.share({
			title: `War Pokemon - ${name}`,
			text: `Check out ${name} (#${id}) on War Pokemon!`,
			url: window.location.href,
		});
	} else {
		navigator.clipboard.writeText(window.location.href).then(() => {
			alert("Link đã được copy vào clipboard!");
		});
	}
};

// Show large image modal
window.showLargeImage = function (imageUrl, altText) {
	const modal = new bootstrap.Modal(document.getElementById("imageModal"));
	const modalImage = document.getElementById("modalImage");
	const modalTitle = document.getElementById("imageModalLabel");

	if (modalImage && modalTitle) {
		modalImage.src = imageUrl;
		modalImage.alt = altText;
		modalTitle.textContent = altText;

		modal.show();
	}
};

// Jump to page function for pagination
window.jumpToPage = function () {
	const pageInput = document.getElementById("jumpToPage");
	const maxPages = parseInt(pageInput.getAttribute("data-max-pages") || "1");
	const baseUrl = pageInput.getAttribute("data-base-url") || "/pokemon/all";
	const pageNumber = parseInt(pageInput.value);

	if (pageNumber >= 1 && pageNumber <= maxPages) {
		window.location.href = `${baseUrl}?page=${pageNumber}`;
	} else {
		alert(`Vui lòng nhập số trang hợp lệ (1 - ${maxPages})`);
	}
};

// Search form handling
window.handleSearchSubmit = function (form) {
	const searchInput = form.querySelector('input[name="search"]');
	const submitBtn = form.querySelector('input[type="submit"]');

	if (searchInput && submitBtn) {
		submitBtn.innerHTML = '<span class="loading-spinner"></span> Đang tìm...';
		submitBtn.disabled = true;

		// Re-enable after 3 seconds as fallback
		setTimeout(() => {
			submitBtn.innerHTML = "Tìm kiếm";
			submitBtn.disabled = false;
		}, 3000);
	}

	return true;
};

// Initialize Pokemon page functionality
document.addEventListener("DOMContentLoaded", function () {
	// Animate stats on show page
	const statFills = document.querySelectorAll(".stat-fill");
	if (statFills.length > 0) {
		setTimeout(() => {
			statFills.forEach((fill, index) => {
				const width = fill.style.width;
				fill.style.width = "0%";
				setTimeout(() => {
					fill.style.width = width;
				}, 100 + index * 100);
			});
		}, 300);
	}

	// Loading animation for Pokemon images
	const sprites = document.querySelectorAll(".pokemon-sprite, .pokemon-image");
	sprites.forEach((sprite, index) => {
		sprite.addEventListener("load", function () {
			this.style.opacity = "0";
			this.style.transform = "scale(0.8)";
			this.style.transition = "all 0.5s ease";

			setTimeout(() => {
				this.style.opacity = "1";
				this.style.transform = "scale(1)";
			}, Math.random() * 200 + index * 50);
		});
	});

	// Enter key support for quick jump
	const jumpToPageInput = document.getElementById("jumpToPage");
	if (jumpToPageInput) {
		jumpToPageInput.addEventListener("keypress", function (e) {
			if (e.key === "Enter") {
				jumpToPage();
			}
		});
	}

	console.log("🎮 War Pokemon JavaScript loaded successfully!");
});
