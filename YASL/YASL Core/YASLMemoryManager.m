//
//  YASLMemoryManager.m
//  YASLVM
//
//  Created by Ankh on 26.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLMemoryManager.h"
#import "YASLRAM.h"
#import "YASLNativeFunctions.h"

typedef struct {
	void *prev, *next;
	YASLInt start, len, end, size;
} MemChunk;

typedef struct {
	MemChunk *firstUsed, *lastUsed;
	MemChunk *firstFree, *lastFree;
	YASLInt start, size, free, used;
} MemoryMap;

MemChunk *_mm_search_chunk(MemChunk *head, YASLInt chunkSize) {
	while (head) {
		if (head->len >= chunkSize)
			return head;

		head = head->next;
	}
	return nil;
}

MemChunk *_mm_chunk(MemChunk *head, YASLInt chunkStart) {
	while (head) {
		if (head->start == chunkStart)
			return head;

		head = head->next;
	}

	return nil;
}

void _mm_insert(MemChunk *chunk, MemChunk **first, MemChunk **last) {
	YASLInt start = chunk->start;
	MemChunk *head = *first, *prev = nil;
	while (head) {
		prev = head;
		head = head->next;
		if (start >= prev->end) {
			if ((!head) || (start < head->start))
				break;
		} else {
			head = prev;
			prev = head->prev;
			break;
		}
	}

	if ((chunk->prev = prev)) prev->next = chunk; else *first = chunk;
	if ((chunk->next = head)) head->prev = chunk; else *last = chunk;
}

YASLInt _mm_alloc(MemoryMap *map, YASLInt allocSize) {
	MemChunk *chunk;
	YASLInt chunkSize = (((allocSize % 4) ? 1 : 0) + (allocSize / 4)) * 4;
	MemChunk *free = _mm_search_chunk(map->firstFree, chunkSize);
	if (free) {
		YASLInt overhead = chunkSize * 11;
		if (free->len > overhead / 10) {
			chunk = malloc(sizeof(MemChunk));
			chunk->start = free->start;
			chunk->len = chunkSize;
			chunk->end = free->start + chunkSize;
			free->start += chunkSize;
			free->len -= chunkSize;
		} else {
			MemChunk *next = free->next;
			MemChunk *prev = free->prev;
			if (next) next->prev = prev; else map->lastFree = prev;
			if (prev) prev->next = next; else map->firstFree = next;

			chunk = free;
		}
		_mm_insert(chunk, &map->firstUsed, &map->lastUsed);
	} else
		return 0;

	chunk->size = allocSize;
	map->free -= chunkSize;
	map->used += chunkSize;
	return chunk->start;
}

YASLInt _mm_dealloc(MemoryMap *map, YASLInt chunkStart) {
	MemChunk *chunk = _mm_chunk(map->firstUsed, chunkStart);
	if (!chunk)
		return 0;

	MemChunk *prev = chunk->prev;
	MemChunk *next = chunk->next;
	if (prev) prev->next = next; else map->firstUsed = next;
	if (next) next->prev = prev; else map->lastUsed = prev;
	_mm_insert(chunk, &map->firstFree, &map->lastFree);

	YASLInt len = chunk->len;
	map->free += len;
	map->used -= len;
	return len;
}

YASLInt _mm_isUsed(MemoryMap *map, YASLInt address) {
	MemChunk *head = map->firstUsed;
	while (head) {
		if ((head->start <= address) && (head->end > address))
			return head->size;

		head = head->next;
	}

	return 0;
}

void _mm_fold_chunks(MemChunk **first, MemChunk **last) {
	MemChunk *search = *first, *prev = search;
	while ((search = search->next)) {
		if (search->start == prev->end) {
			prev->len += search->len;
			prev->end = search->end;

			if ((prev->next = search->next)) {
				((MemChunk *)prev->next)->prev = prev;
			}
			free(search);
			search = prev;
		}
	}
	*last = prev;
}

void _mm_init(MemoryMap *map, YASLInt start, YASLInt size) {
	MemChunk *chunk = malloc(sizeof(MemChunk));
	chunk->start = start;
	chunk->len = size;
	chunk->end = start + size;
	chunk->prev = nil;
	chunk->next = nil;

	map->size = size;
	map->free = size;
	map->used = 0;
	map->firstUsed = nil;
	map->lastUsed = nil;
	map->firstFree = chunk;
	map->lastFree = chunk;
}

void _mm_deinit(MemoryMap *map) {
	MemChunk *next = map->firstUsed, *tmp;
	while (next) {
		tmp = next;
		next = next->next;
		free(tmp);
	}
	next = map->firstFree;
	while (next) {
		tmp = next;
		next = next->next;
		free(tmp);
	}
	map->firstUsed = nil;
	map->firstFree = nil;
	map->lastUsed = nil;
	map->lastFree = nil;
}

@implementation YASLMemoryManager {
	MemoryMap memMap;
	long long lastGCTick;
	float proubability;
}


- (id)init {
	if (!(self = [super init]))
		return self;

	[YASLNativeFunctions sharedFunctions].attachedMM = self;

	proubability = 1.1;
	lastGCTick = [NSDate timeIntervalSinceReferenceDate];
	return self;
}
- (id)initWithRAM:(YASLRAM *)ram {
	if (!(self = [self init]))
		return self;

	[self setRam:ram];
	return self;
}

- (void)dealloc
{
	self.ram = nil;
}

+ (instancetype) memoryManagerForRAM:(YASLRAM *)ram {
	return [[self alloc] initWithRAM:ram];
}

- (void) setRam:(YASLRAM *)ram {
	if (_ram == ram)
		return;

	_ram = ram;
	if (ram) {
		_mm_init(&memMap, 0, _ram.size);
		// allocate first 64kB of heap space to detect null pointers
		[self allocMem:64 * 1024];
	} else
		_mm_deinit(&memMap);
}

- (YASLInt) allocMem:(YASLInt)size {
	return _mm_alloc(&memMap, size);
}

- (YASLInt) deallocMem:(YASLInt)mem {
	return _mm_dealloc(&memMap, mem);
}

- (YASLInt) isAllocated:(YASLInt)mem {
	return _mm_isUsed(&memMap, mem);
}

- (void) serveGC {
	long long tick = [NSDate timeIntervalSinceReferenceDate];
	if (tick - lastGCTick > 15) {
		_mm_fold_chunks(&memMap.firstFree, &memMap.lastFree);
		lastGCTick = tick;
	}
}

@end
