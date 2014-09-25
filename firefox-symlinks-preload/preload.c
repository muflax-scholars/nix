	#define _GNU_SOURCE
	#include <dlfcn.h>
	#include <dirent.h>
	#include <errno.h>
	#include <fcntl.h>
	#include <stdio.h>
	#include <string.h>
	#include <sys/socket.h>
	#include <sys/stat.h>
	#include <sys/types.h>
	#include <unistd.h>

	
	int
	__lxstat(int ver, const char *path, struct stat *buf)
	{
		static int (*real_lxstat)(int, const char*, struct stat*);
		static int (*real_xstat)(int, const char*, struct stat*);
		int ret = -1;

		if (!real_lxstat) {
			real_lxstat = dlsym(RTLD_NEXT, "__lxstat");
			real_xstat = dlsym(RTLD_NEXT, "__xstat");
			if (!real_xstat || !real_lxstat) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_lxstat(ver, path, buf);
		if (ret != 0) goto out;

		if (S_ISLNK(buf->st_mode)) {
			struct stat tmp;

			ret = real_xstat(ver, path, &tmp);
			if (ret != 0) {
				// We can still use the lstat result.
				ret = 0;
				goto out;
			}

			if (S_ISDIR(tmp.st_mode)) {
				*buf = tmp;
			} else if (S_ISREG(tmp.st_mode)
					&& ((tmp.st_mode & 0111) == 0)) {
				*buf = tmp;
			}
		}
	out:
		return ret;
	}
	
	int
	__lxstat64(int ver, const char *path, struct stat64 *buf)
	{
		static int (*real_lxstat64)(int, const char*, struct stat64*);
		static int (*real_xstat64)(int, const char*, struct stat64*);
		int ret = -1;

		if (!real_lxstat64) {
			real_lxstat64 = dlsym(RTLD_NEXT, "__lxstat64");
			real_xstat64 = dlsym(RTLD_NEXT, "__xstat64");
			if (!real_xstat64 || !real_lxstat64) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_lxstat64(ver, path, buf);
		if (ret != 0) goto out;

		if (S_ISLNK(buf->st_mode)) {
			struct stat64 tmp;

			ret = real_xstat64(ver, path, &tmp);
			if (ret != 0) {
				// We can still use the lstat64 result.
				ret = 0;
				goto out;
			}

			if (S_ISDIR(tmp.st_mode)) {
				*buf = tmp;
			} else if (S_ISREG(tmp.st_mode)
					&& ((tmp.st_mode & 0111) == 0)) {
				*buf = tmp;
			}
		}
	out:
		return ret;
	}
	
	static void
	fix_dirent(DIR *dir, struct dirent *ent)
	{
		if (ent->d_type == DT_LNK || ent->d_type == DT_UNKNOWN) {
			int fd = openat(dirfd(dir), &ent->d_name[0], O_RDONLY);
			if (fd >= 0) {
				struct stat64 stbuf;
				if (fstat64(fd, &stbuf) == 0) {
					if (S_ISREG(stbuf.st_mode)) {
						ent->d_type = DT_REG;
					} else if (S_ISDIR(stbuf.st_mode)) {
						ent->d_type = DT_DIR;
					} else if (S_ISFIFO(stbuf.st_mode)) {
						ent->d_type = DT_FIFO;
					} else if (S_ISCHR(stbuf.st_mode)) {
						ent->d_type = DT_CHR;
					} else if (S_ISBLK(stbuf.st_mode)) {
						ent->d_type = DT_BLK;
					} else if (S_ISSOCK(stbuf.st_mode)) {
						ent->d_type = DT_SOCK;
					}
				}
				do {} while (close(fd) != 0 && errno == EINTR);
			}
		}
	}

	struct dirent*
	readdir(DIR *dir)
	{
		static struct dirent* (*real_readdir)(DIR*);
		struct dirent *ret = NULL;

		if (!real_readdir) {
			real_readdir = dlsym(RTLD_NEXT, "readdir");
			if (!real_readdir) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_readdir(dir);
		if (ret) {
			fix_dirent(dir, ret);
		}
	out:
		return ret;
	}

	int
	readdir_r(DIR *dir, struct dirent *entry, struct dirent **result)
	{
		static int (*real_readdir_r)(DIR*,
				struct dirent*, struct dirent*);
		int ret = -1;

		if (!real_readdir_r) {
			real_readdir_r = dlsym(RTLD_NEXT, "readdir_r");
			if (!real_readdir_r) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_readdir_r(dir, entry, *result);
		if (ret == 0 && *result) {
			fix_dirent(dir, *result);
		}
	out:
		return ret;
	}
	
	static void
	fix_dirent64(DIR *dir, struct dirent64 *ent)
	{
		if (ent->d_type == DT_LNK || ent->d_type == DT_UNKNOWN) {
			int fd = openat(dirfd(dir), &ent->d_name[0], O_RDONLY);
			if (fd >= 0) {
				struct stat64 stbuf;
				if (fstat64(fd, &stbuf) == 0) {
					if (S_ISREG(stbuf.st_mode)) {
						ent->d_type = DT_REG;
					} else if (S_ISDIR(stbuf.st_mode)) {
						ent->d_type = DT_DIR;
					} else if (S_ISFIFO(stbuf.st_mode)) {
						ent->d_type = DT_FIFO;
					} else if (S_ISCHR(stbuf.st_mode)) {
						ent->d_type = DT_CHR;
					} else if (S_ISBLK(stbuf.st_mode)) {
						ent->d_type = DT_BLK;
					} else if (S_ISSOCK(stbuf.st_mode)) {
						ent->d_type = DT_SOCK;
					}
				}
				do {} while (close(fd) != 0 && errno == EINTR);
			}
		}
	}

	struct dirent64*
	readdir64(DIR *dir)
	{
		static struct dirent64* (*real_readdir64)(DIR*);
		struct dirent64 *ret = NULL;

		if (!real_readdir64) {
			real_readdir64 = dlsym(RTLD_NEXT, "readdir64");
			if (!real_readdir64) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_readdir64(dir);
		if (ret) {
			fix_dirent64(dir, ret);
		}
	out:
		return ret;
	}

	int
	readdir64_r(DIR *dir, struct dirent64 *entry, struct dirent64 **result)
	{
		static int (*real_readdir64_r)(DIR*,
				struct dirent64*, struct dirent64*);
		int ret = -1;

		if (!real_readdir64_r) {
			real_readdir64_r = dlsym(RTLD_NEXT, "readdir64_r");
			if (!real_readdir64_r) {
				errno = ELIBACC;
				goto out;
			}
		}

		ret = real_readdir64_r(dir, entry, *result);
		if (ret == 0 && *result) {
			fix_dirent64(dir, *result);
		}
	out:
		return ret;
	}
